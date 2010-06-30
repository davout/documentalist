require 'test_helper'

class OpenOfficeTest < Test::Unit::TestCase
  @@oo_server = Documentalist::OpenOffice::Server

  def setup
    # Make our test reproductible
    @@oo_server.kill! if @@oo_server.running?
  end

  def test_open_office_converts_from_odf_to_pdf
    destination = File.join(Dir.tmpdir, "#{rand(10**9)}.doc")

    Documentalist.convert fixture_001, :to => destination

    assert File.exist?(destination), "Nothing seems to have been converted..."

    FileUtils.rm destination
    assert !File.exist?(destination), "We didn't clean up our mess!"
  end

  def test_open_office_should_obey
    assert !@@oo_server.running?, "OpenOffice service is running, it shouldn't be"

    @@oo_server.start!
    assert @@oo_server.running?, "OpenOffice didn't start"

    pids = @@oo_server.pids
    assert !(pids.nil? or pids.empty?),  "Oops, pid was blank!"

    @@oo_server.restart!
    assert_not_equal pids, @@oo_server.pids, "Seems like OpenOffice didn't actually get restarted"
  end

  def test_open_office_should_explode_if_no_destination_given
    assert_raise Documentalist::Error do
      # We want to make sure an exception is raised if no destination is passed
      Documentalist.convert(__FILE__)
    end
  end
end
