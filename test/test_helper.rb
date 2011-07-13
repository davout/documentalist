require 'rubygems'
require 'active_record'
require 'logger'
gem 'sqlite3-ruby'

require 'test/unit'
require 'flexmock/test_unit'

require 'ruby-debug'
Debugger.start
Debugger.settings[:autoeval] = true


ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__),'documentalist.log'))
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => File.join(File.dirname(__FILE__),'documentalist.sqlite'))
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.default_timezone = :utc if Time.zone.nil?

ActiveRecord::Schema.define do
  create_table :delayed_jobs, :force => true do |table|
    table.integer  :priority, :default => 0
    table.integer  :attempts, :default => 0
    table.text     :handler
    table.string   :last_error
    table.datetime :run_at
    table.datetime :locked_at
    table.string   :locked_by
    table.datetime :failed_at
    table.timestamps
  end
end

require 'delayed_job'
Delayed::Worker.guess_backend

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