require_relative "lib/configurable_from_env/version"

Gem::Specification.new do |spec|
  spec.name = "configurable_from_env"
  spec.version = ConfigurableFromEnv::VERSION
  spec.authors = ["Matt Brictson"]
  spec.email = ["opensource@mattbrictson.com"]

  spec.summary = "Define accessors that are automatically populated via ENV"
  spec.homepage = "https://github.com/mattbrictson/configurable_from_env"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/mattbrictson/configurable_from_env/issues",
    "changelog_uri" => "https://github.com/mattbrictson/configurable_from_env/releases",
    "source_code_uri" => "https://github.com/mattbrictson/configurable_from_env",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[LICENSE.txt README.md {exe,lib}/**/*]).reject { |f| File.directory?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "activesupport", ">= 7.2"
end
