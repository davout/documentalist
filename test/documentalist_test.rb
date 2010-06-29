require 'test_helper'

class DocumentalistTest < Test::Unit::TestCase
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
    assert false, "Implement me"

    # timeout should work with long system call, only if system timer is used
    # tho, it should be checked moar in case default timeout handles it well
  end
end
