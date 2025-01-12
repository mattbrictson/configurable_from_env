require "active_support"
require "active_support/concern"
require "active_support/core_ext/enumerable"
require "active_support/core_ext/hash/keys"

module ConfigurableFromEnv
  autoload :Configurable, "configurable_from_env/configurable"
  autoload :EnvironmentValue, "configurable_from_env/environment_value"
  autoload :VERSION, "configurable_from_env/version"

  extend ActiveSupport::Concern
  include Configurable

  module ClassMethods
    def config_accessor(*attributes, from_env: nil, **options, &block)
      if from_env && attributes.many?
        raise ArgumentError, "Only one accessor at a time can be created using the :from_env option"
      end

      env_value = EnvironmentValue.from(from_env)
      accessor = super(*attributes, **options, &block)
      default_provided = options.key?(:default) || block_given?

      env_value&.read(required: !default_provided) do |value|
        public_send(:"#{attributes.first}=", value)
      end

      accessor
    end
  end
end
