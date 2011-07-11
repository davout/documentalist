require 'rubygems'

require 'ruby-debug'
Debugger.start
Debugger.settings[:autoeval] = true

require 'test/unit'
require 'flexmock/test_unit'

require File.expand_path File.dirname(__FILE__) + '/../lib/documentalist'

Documentalist.init(File.dirname(__FILE__), File.join(File.dirname(__FILE__), 'config/documentalist.yml'))




def fixture_001
  File.join(File.dirname(__FILE__), "fixtures/fixture_001.odt")
end

def fixture_002
  File.join(File.dirname(__FILE__), "fixtures/fixture_002.html")
end

class Test::Unit::TestCase
  def assert_difference(code, difference = 0, message = nil)
    message = "Returned values were equal" unless message
    start_value = eval(code).to_i
    yield
    end_value = eval(code).to_i

    if difference
      assert_equal difference, end_value - start_value, message
    else
      assert((end_value - start_value) != 0, message)
    end
  end

  def assert_no_difference(code, message = "Returned values were different")
    assert_difference(code, 0, message) do
      yield
    end
  end
end