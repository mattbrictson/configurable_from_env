require "test_helper"

module ConfigurableFromEnv
  class VersionTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::ConfigurableFromEnv::VERSION
    end
  end
end
