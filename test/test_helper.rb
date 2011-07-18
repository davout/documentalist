require 'rubygems'
require 'logger'
gem 'sqlite3-ruby'

require 'test/unit'
require 'flexmock/test_unit'

require 'ruby-debug'
Debugger.start
Debugger.settings[:autoeval] = true


require File.expand_path File.dirname(__FILE__) + '/../lib/documentalist'

Documentalist.init(File.dirname(__FILE__), File.join(File.dirname(__FILE__), 'config/documentalist.yml'))

def fixture_001
  File.join(File.dirname(__FILE__), "fixtures/fixture_001.odt")
end

def fixture_002
  File.join(File.dirname(__FILE__), "fixtures/fixture_002.html")
end

def mock_resque
  mock = flexmock(Documentalist::OpenOffice::Converter).should_receive(:create).and_return do |options|
    Documentalist::OpenOffice.convert_without_no_concurent_access(options[:origin], options)
  end

  mock_2 = flexmock(::Resque::Status).should_receive(:get).and_return do
    status = ::Resque::Status.new
    status.status = "completed"
    status
  end
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