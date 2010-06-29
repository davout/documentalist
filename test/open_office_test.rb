require 'test_helper'

class OpenOfficeTest < Test::Unit::TestCase
  def test_open_office_converts_from_odf_to_pdf
    destination = File.join(Dir.tmpdir, "#{rand(10**9)}.pdf")

    Documentalist.convert(
      fixture_001,
      destination
    )

    assert File.exist?(destination), "Nothing seems to have been converted..."

    FileUtils.rm destination
    assert !File.exist?(destination), "We didn't clean up our mess!"
  end
end
