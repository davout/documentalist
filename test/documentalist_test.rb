#require File.join(File.dirname(__FILE__),'test_helper.rb')
require "test_helper"
require 'tmpdir'

class DocumentalistTest < Test::Unit::TestCase
  include FlexMock::TestCase

  ## Test the custom symbolize method used as a replacement for the Active Support version
  #def test_symbolize
  #  hash = { "a" => "b",
  #    "c" => {
  #      "d" => "e"
  #    }
  #  }
  #
  #  symbolized = { :a => "b",
  #    :c => {
  #      :d => "e"
  #    }
  #  }
  #
  #  assert_equal Documentalist.send(:symbolize, hash),
  #    symbolized,
  #    "Hash wasn't properly symbolized"
  #end

  # Test that we use a system timeout and not a green thread based timeout that
  # could possibly not work on some long external system calls
  def test_timeout_uses_system_timeout
    flexmock(Timeout).should_receive(:timeout).once
    Documentalist::OpenOffice::Server.timeout(0.1) { }
  end

  # Test that we have a default configuration for Documentalist even if
  def test_default_config
    # Check that we did not get some Rails context from other tests
    assert !Object.const_defined?(:RAILS_ENV)

    # Check that at least a configuration key has been magically set
    assert Documentalist.config[:open_office]
  end

  # todo : a reprendre, le logger étant créé une fois pour toute lors de l'init de Documentalist
  #def test_logger
  #  log_file = File.join(Dir.tmpdir, "#{rand(10 ** 9).to_s}.log")
  #
  #  Documentalist.config[:log_path] = log_file
  #  Documentalist.config[:log_level] = 'warn'
  #
  #  # Reset logger
  #  Documentalist.logger= nil
  #
  #  assert !File.exists?(log_file), "Log file already exists"
  #
  #  Documentalist.logger
  #  assert File.exists?(log_file), "Log file should have been created"
  #
  #  assert_no_difference("File.size(\"#{log_file}\")", "Nothing should have been written") do
  #    Documentalist.logger.debug("This message should go nowhere")
  #  end
  #
  #  assert_difference("File.size(\"#{log_file}\")", nil, "Nothing should have been written") do
  #    Documentalist.logger.warn("This message should be written !")
  #  end
  #
  #  # Reset logger
  #  Documentalist.send :class_variable_set, :@@logger, nil
  #
  #  FileUtils.rm(log_file)
  #  assert !File.exists?(log_file), "Log file hasn't been removed properly"
  #end

  def test_extract_text
    mock_resque
    assert_match /thing/,
      Documentalist.extract_text(fixture_001),
      "Text was not properly extracted for fixture 001"
  end


  def test_extract_stream
    mock_resque

    returned_data = Documentalist.convert(fixture_001, :stream => :txt) do |data|
      assert_match /thing/, data, "Converted data wasn't streamed properly"
      data
    end

    assert_match /thing/, returned_data, "Converted data wasn't streamed properly"
  end
end
