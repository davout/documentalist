require 'test/unit'
require 'documentalist'
require 'fileutils'
require 'tmpdir'

class OpenOfficeTest < Test::Unit::TestCase
  def test_open_office
    destination = File.join(Dir.tmpdir, "fixture#{rand(10**9)}.pdf")

    Documentalist.convert(
      File.join(File.dirname(__FILE__), "fixtures", "fixture.odt"),
      destination
    )

    assert File.exist?(destination)

    FileUtils.rm(destination)

    assert !File.exist?(destination)
  end
end
