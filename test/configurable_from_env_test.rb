require "test_helper"

class ConfigurableFromEnvTest < Minitest::Test
  def setup
    @class = Class.new
    @class.include ConfigurableFromEnv
  end

  def teardown
    ENV.delete("TEST_API_KEY")
    ENV.delete("TEST_TIMEOUT")
  end

  def test_defines_accessor_with_no_env_source
    @class.config_accessor :logger

    assert_respond_to @class, :logger
    assert_respond_to @class, :logger=
  end

  def test_defines_multiple_accessors_with_no_env_source
    @class.config_accessor :http_client, :logger

    assert_respond_to @class, :http_client
    assert_respond_to @class, :http_client=
    assert_respond_to @class, :logger
    assert_respond_to @class, :logger=
  end

  def test_raises_if_multiple_accessors_declared_with_one_env_option
    error = assert_raises(ArgumentError) { @class.config_accessor :api_key, :logger, from_env: "TEST_API_KEY" }
    assert_match "Only one accessor at a time can be created using the :from_env option", error.message
  end

  def test_defines_accessor_with_key_and_implicit_type
    @class.config_accessor :api_key, from_env: "TEST_API_KEY", default: nil

    assert_respond_to @class, :api_key
    assert_respond_to @class, :api_key=
  end

  def test_defines_accessor_with_key_and_type
    @class.config_accessor :timeout, from_env: { key: "TEST_TIMEOUT", type: :integer }, default: 30

    assert_respond_to @class, :timeout
    assert_respond_to @class, :timeout=
  end

  def test_uses_default_value_when_env_var_is_absent
    @class.config_accessor :timeout, from_env: { key: "TEST_TIMEOUT", type: :integer }, default: 30

    assert_equal 30, @class.timeout
  end

  def test_assigns_integer_env_var_value_overriding_default
    ENV["TEST_TIMEOUT"] = "5"
    @class.config_accessor :timeout, from_env: { key: "TEST_TIMEOUT", type: :integer }, default: 30

    assert_equal 5, @class.timeout
  end

  def test_assigns_string_env_var_value_with_no_default
    ENV["TEST_API_KEY"] = "secret"
    @class.config_accessor :api_key, from_env: "TEST_API_KEY"

    assert_equal "secret", @class.api_key
  end

  def test_raises_if_no_default_and_env_var_is_absent
    error = assert_raises(ArgumentError) { @class.config_accessor :api_key, from_env: "TEST_API_KEY" }
    assert_match "Missing required environment variable: TEST_API_KEY", error.message
  end
end
