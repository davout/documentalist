require 'test_helper'
require 'system_timer'

class DocumentalistTest < Test::Unit::TestCase
  include FlexMock::TestCase

  # Test the custom symbolize method used as a replacement for the Active Support version
  def test_symbolize
    hash = { "a" => "b",
      "c" => {
        "d" => "e"
      }
    }

    symbolized = { :a => "b",
      :c => {
        :d => "e"
      }
    }
    
    assert_equal Documentalist.send(:symbolize, hash), 
      symbolized,
      "Hash wasn't properly symbolized"
  end

  # Test that we use a system timeout and not a green thread based timeout that
  # could possibly not work on some external system calls
  def test_timeout_uses_system_timeout
    flexmock(SystemTimer).should_receive(:timeout).once
    Documentalist.timeout(0.1) { }
  end

  # Test that we have a default configuration for Documentalist even if
  def test_default_config
    # Check that we did not get some Rails context from other tests
    assert !Object.const_defined?(:RAILS_ENV)

    # Check that at least a configuration key has been magically set
    assert Documentalist.config[:open_office]
  end
end
