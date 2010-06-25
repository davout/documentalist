require File.dirname(__FILE__) + '/test_helper'

class ProselytismTest < ActiveSupport::TestCase

  def setup
    # Pour avoir un test compltement reproductible
    Proselytism::Servers::OpenOffice.kill! if Documents::Servers::OpenOffice.running?
  end

  def test_open_office_should_obey
    assert !Proselytism::Servers::OpenOffice.running?, "OpenOffice is running, it shouldn't be"

    Proselytism::Servers::OpenOffice.start!
    assert Proselytism::Servers::OpenOffice.running?, "OpenOffice didn't start"

    pids = Proselytism::Servers::OpenOffice.pids
    assert !pids.blank?,  "Oops, pid was nil!"

    Proselytism::Servers::OpenOffice.restart!
    assert_not_equal pids, Proselytism::Servers::OpenOffice.pids, "Seems like OO didn't actually get restarted"
  end

  def test_document_should_be_converted
    test_file = File.dirname(__FILE__) + "/fixtures/fixture001.odt"
    converted_doc = Proselytism.convert(test_file, :to => :txt)

    assert File.exist?(converted_doc)
    content_converted_file = File.open(converted_doc).read
    assert_equal false, content_converted_file.blank?
    
    system("rm -f #{converted_doc}")
    assert !File.exist?(converted_doc)
  end

end
