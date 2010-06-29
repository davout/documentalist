require 'test_helper'

class DocumentalistTest < Test::Unit::TestCase
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
end
