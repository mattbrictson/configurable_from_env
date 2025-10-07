# configurable_from_env

[![Gem Version](https://img.shields.io/gem/v/configurable_from_env)](https://rubygems.org/gems/configurable_from_env)
[![Gem Downloads](https://img.shields.io/gem/dt/configurable_from_env)](https://www.ruby-toolbox.com/projects/configurable_from_env)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/mattbrictson/configurable_from_env/ci.yml)](https://github.com/mattbrictson/configurable_from_env/actions/workflows/ci.yml)

The `configurable_from_env` gem allows you to define accessors that automatically populate via environment variables. It brings back Active Support's [`config_accessor`](https://github.com/rails/rails/blob/819a94934966eafb6bee6990b18372e1eb91159d/activesupport/lib/active_support/configurable.rb#L111) – which was [deprecated](https://github.com/rails/rails/pull/53970) in Rails 8.1 – and enhances it with a new `:from_env` option.

> [!NOTE]
> This project is experimental. Please open an issue or send me an email and let me know what you think!

---

- [Quick start](#quick-start)
- [Motivation](#motivation)
- [Support](#support)
- [License](#license)
- [Code of conduct](#code-of-conduct)
- [Contribution guide](#contribution-guide)

## Quick start

Add the gem to your Gemfile and run `bundle install`:

```ruby
gem "configurable_from_env"
```

Include the `ConfigurableFromEnv` mixin and then use `config_accessor` to define configurable attributes that are automatically populated from the environment.

```ruby
class MyHttpClient
  include ConfigurableFromEnv

  # Define an api_key accessor that is automatically populated from ENV["MY_API_KEY"]
  config_accessor :api_key, from_env: "MY_API_KEY"

  # Validate and convert ENV value into a desired data type
  config_accessor :timeout, from_env: { key: "MY_TIMEOUT", type: :integer }

  # Fall back to a default value if the environment variable is absent
  config_accessor :verify_tls, from_env: { key: "MY_VERIFY_TLS", type: :boolean }, default: true

  def fetch_data
    # Config attributes are exposed as instance methods for easy access
    conn = Faraday.new(
      headers: { "X-API-Key" => api_key },
      request: { timeout: timeout },
      ssl: { verify: verify_tls }
    )
    conn.get("https://my.api/data")
  end
end
```

## Motivation

Rails lacks a simple way to declare configuration dependencies on `ENV` values. Generally, the framework guides you toward one of two common approaches:

**Use `ENV.fetch` directly when you need a value.** This is the most direct technique, but it means that `ENV` dependencies are scattered throughout implementation code. Testing can become more difficult due to this implicit global variable dependency, and you may need a special library to mock `ENV` access.

**Define a configuration object, and use an initializer to copy values from `ENV` into the config.** Third-party gems often use this approach. Consider Devise, which uses `config/initializers/devise.rb`.

```ruby
Devise.setup do |config|
  config.secret_key = ENV.fetch("DEVISE_SECRET_KEY")
```

This is very flexible, and works well for libraries that need to be portable across many different app environments. However for application-level code it can repetitive, as each configuration attribute has to be declared multiple times, often in 3 separate files:

1. Define a configuration class that declares the attribute.
2. Create an initializer that sets the attribute.
3. Reference the configuration when using the attribute.

**Regardless of where you put the `ENV` access, validating and converting values can be tedious.** Environment values are always strings, but often we need them to configure settings that are booleans or integers.

### A different approach

`configurable_from_env` is an extremely lightweight solution (~80 LOC) to the shortcomings listed above. Consider this example:

```ruby
class MyHttpClient
  include ConfigurableFromEnv
  config_accessor :timeout, from_env: { key: "MY_TIMEOUT", type: :integer }, default: 30
```

The benefits are:

- Configurable attributes, their default values, how they map from environment variables, and their data types are all declared in one place, as opposed to scattered across initializers, classes, and/or YAML files.
- The configuration is colocated with the code where it used (i.e. the `MyHttpClient` class, in the example).
- Because these are simple accessors, values can be easily injected in unit tests without needing to mock `ENV`.
- Specifying a `:type` takes care of validation and conversion of environment values with an intuitive and concise syntax.

## Support

If you want to report a bug, or have ideas, feedback or questions about the gem, [let me know via GitHub issues](https://github.com/mattbrictson/configurable_from_env/issues/new) and I will do my best to provide a helpful answer. Happy hacking!

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Code of conduct

Everyone interacting in this project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Contribution guide

Pull requests are welcome!
