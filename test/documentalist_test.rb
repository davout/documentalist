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
  
  def test_timeout_uses_system_timeout
    flexmock(SystemTimer).should_receive(:timeout).once
    Documentalist.timeout(0.1) { }
  end
end
