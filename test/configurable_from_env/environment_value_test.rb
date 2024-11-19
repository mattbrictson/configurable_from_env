require "test_helper"

module ConfigurableFromEnv
  class EnvironmentValueTest < Minitest::Test
    def test_from_implicit_type
      value = EnvironmentValue.from("TEST")

      assert_equal "TEST", value.key
      assert_equal :string, value.type
    end

    def test_from_explicit_type
      value = EnvironmentValue.from({ key: "TEST", type: :boolean })

      assert_equal "TEST", value.key
      assert_equal :boolean, value.type
    end

    def test_from_invalid_options
      error = assert_raises(ArgumentError) { EnvironmentValue.from({ key: "TEST", type: :boolean, optional: true }) }
      assert_match "Unknown key: :optional. Valid keys are: :key, :type", error.message
    end

    def test_from_unknown_type
      error = assert_raises(ArgumentError) { EnvironmentValue.from({ key: "TEST", type: :date }) }
      assert_match "Invalid type: :date (must be one of :boolean, :integer, :string)", error.message
    end

    def test_read_string
      value = EnvironmentValue.new(key: "TEST", type: :string, env: { "TEST" => "hello" })

      assert_equal "hello", value.read
    end

    def test_read_yields_value
      value = EnvironmentValue.new(key: "TEST", type: :string, env: { "TEST" => "hello" })
      yielded = :nothing
      value.read { yielded = _1 }

      assert_equal "hello", yielded
    end

    def test_read_required_value_raises_if_env_var_is_absent
      value = EnvironmentValue.new(key: "TEST", type: :string, env: {})

      error = assert_raises(ArgumentError) { value.read(required: true) }
      assert_match "Missing required environment variable: TEST", error.message
    end

    def test_read_optional_value_returns_nil_and_does_not_yield_if_env_var_is_absent
      value = EnvironmentValue.new(key: "TEST", type: :string, env: {})

      yielded = :nothing
      returned = value.read(required: false) { yielded = _1 }

      assert_nil returned
      assert_equal :nothing, yielded
    end

    def test_read_true_booleans
      %w[1 true yes t y enable enabled on].each do |env_value|
        value = EnvironmentValue.new(key: "TEST", type: :boolean, env: { "TEST" => env_value })

        assert_equal true, value.read
      end
    end

    def test_read_false_booleans
      %w[0 false no f n disable disabled off].each do |env_value|
        value = EnvironmentValue.new(key: "TEST", type: :boolean, env: { "TEST" => env_value })

        assert_equal false, value.read
      end
    end

    def test_read_empty_string_is_false_boolean
      value = EnvironmentValue.new(key: "TEST", type: :boolean, env: { "TEST" => "" })

      assert_equal false, value.read
    end

    def test_read_upper_case_boolean
      value = EnvironmentValue.new(key: "TEST", type: :boolean, env: { "TEST" => "YES" })

      assert_equal true, value.read
    end

    def test_read_invalid_boolean
      value = EnvironmentValue.new(key: "TEST", type: :boolean, env: { "TEST" => "what" })

      error = assert_raises(ArgumentError) { value.read }
      assert_match 'Environment variable TEST has an invalid boolean value: "what"', error.message
    end

    def test_read_valid_integer
      value = EnvironmentValue.new(key: "TEST", type: :integer, env: { "TEST" => "25" })

      assert_equal 25, value.read
    end

    def test_read_valid_negative_integer
      value = EnvironmentValue.new(key: "TEST", type: :integer, env: { "TEST" => "-1" })

      assert_equal(-1, value.read)
    end

    def test_read_invalid_integer
      value = EnvironmentValue.new(key: "TEST", type: :integer, env: { "TEST" => "1A" })

      error = assert_raises(ArgumentError) { value.read }
      assert_match 'Environment variable TEST has an invalid integer value: "1A"', error.message
    end
  end
end
