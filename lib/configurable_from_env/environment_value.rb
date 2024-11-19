module ConfigurableFromEnv
  class EnvironmentValue
    TYPES = %i[boolean integer string].freeze

    BOOLEAN_VALUES = {}.merge(
      %w[1 true yes t y enable enabled on].to_h { [_1, true] },
      %w[0 false no f n disable disabled off].to_h { [_1, false] },
      { "" => false }
    ).freeze

    def self.from(definition)
      return nil if definition.nil?

      definition = { key: definition } unless definition.is_a?(Hash)
      definition.assert_valid_keys(:key, :type)
      new(**definition)
    end

    attr_reader :key, :type

    def initialize(key:, type: :string, env: ENV)
      unless TYPES.include?(type)
        raise ArgumentError, "Invalid type: #{type.inspect} (must be one of #{TYPES.map(&:inspect).join(', ')})"
      end

      @key = key
      @type = type
      @env = env
    end

    def read(required: true)
      if env.key?(key)
        value = convert(env[key])
        block_given? ? yield(value) : value
      elsif required
        raise ArgumentError, "Missing required environment variable: #{key}"
      end
    end

    private

    attr_reader :env

    def convert(value)
      send(:"convert_to_#{type}", value)
    rescue ArgumentError
      raise ArgumentError, "Environment variable #{key} has an invalid #{type} value: #{value.inspect}"
    end

    def convert_to_boolean(value)
      BOOLEAN_VALUES.fetch(value&.downcase&.strip) do
        raise ArgumentError, "Boolean value must be one of #{BOOLEAN_VALUES.keys.join(', ')}"
      end
    end

    def convert_to_integer(value)
      Integer(value)
    end

    def convert_to_string(value)
      value.to_s
    end
  end
end
