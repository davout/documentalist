require 'test_helper'

class PdfToolsTest < Test::Unit::TestCase
  def test_pdf_tools_binaries_are_present
    assert !`which pdfimages`.empty?, "Can't seem to find pdfimages binary"
    assert !`which pdftotext`.empty?, "Can't seem to find pdftotext binary"
  end
end
