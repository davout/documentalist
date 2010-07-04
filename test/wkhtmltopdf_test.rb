require 'test_helper'

class WkHtmlToPdfTest < Test::Unit::TestCase
  def test_right_backend_is_picked
    assert_equal Documentalist.backend_for_conversion("test.html", "test.pdf"),
      Documentalist::WkHtmlToPdf,
      "Wrong backend picked"
  end

  def test_conversion
    temp_file = File.join(Dir.tmpdir, "#{rand(10**9)}.pdf")

    Documentalist.convert(fixture_002, :to => temp_file)
    assert File.exists?(temp_file), "No converted PDF created"

    assert_match /Test content/, Documentalist.extract_text(temp_file)

    FileUtils.rm temp_file
    assert !File.exists?(temp_file), "We didn't clean up properly"
  end
end
