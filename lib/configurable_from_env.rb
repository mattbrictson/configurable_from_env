require "active_support"
require "active_support/concern"
require "active_support/configurable"
require "active_support/core_ext/enumerable"
require "active_support/core_ext/hash/keys"

module ConfigurableFromEnv
  autoload :EnvironmentValue, "configurable_from_env/environment_value"
  autoload :VERSION, "configurable_from_env/version"
end
