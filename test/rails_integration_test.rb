require 'test_helper'
require 'tmpdir'

class RailsIntegrationTest < Test::Unit::TestCase
  def test_config_file_gets_copied_and_loaded
    # Undefine Documentalist so we don't get annoying warnings about constant redefinition
    # when redefining Documentalist::BACKENDS when requiring it a second time after it
    # being required a first time through the 'test_helper' require
    Object.send(:remove_const, :Documentalist)

    # Ensure that RAILS_ROOT is undefined
    assert !Object.const_defined?(:RAILS_ROOT), "RAILS_ROOT constant is defined, I won't go further"

    # Set up a fake RAILS_ROOT
    tmp_dir = Object.const_set :RAILS_ROOT, File.join(Dir.tmpdir, (rand(10**9)).to_s)
    FileUtils.mkdir_p File.join(tmp_dir, "config")

    # Set up a fake RAILS_ENV
    Object.const_set :RAILS_ENV, "development"

    # Initialize in fake Rails context
    require File.join(File.dirname(__FILE__), %w{.. rails install})

    # Check that the configuration got loaded up properly
    assert_equal Documentalist.config[:python][:path], '/usr/bin/python'

    # Check that our configuration template got copied
    assert File.exists?(File.join(RAILS_ROOT, %w{config documentalist.yml})),
      "Configuration file did not get copied properly"

    assert_equal Documentalist.config[:log_file], File.join(RAILS_ROOT, "log", "documentalist-#{RAILS_ENV}.log")

    # Delete fake RAILS_ROOT
    FileUtils.rm_rf tmp_dir

    # Reset logger

    # Check that we cleaned our mess up
    assert !File.exist?(File.join(RAILS_ROOT, %w{config documentalist.yml})), "Temporary file hasn't been removed properly"
  end
end
