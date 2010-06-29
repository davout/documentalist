require 'test_helper'

class ODFMergeTest < Test::Unit::TestCase
  @@odf_file = File.join(File.dirname(__FILE__), "fixtures/fixture_001.odt")

  # Tests that an arbitrary hash of data gets correctly merged into a string template
  def test_merge
    template = "<%= @var1 %><%= 1.upto(3).map{ |n| n.to_s }.join %><%= @var2 %>"

    merged = Documentalist::ODFMerge.merge_string(template, :locals => {
        :var1 => "test",
        :var2 => "working?"
      }
    )

    assert_equal "test123working?", merged, "Merge wasn't performed correctly"
  end

  # Tests that the ODFMerge backend correctly extracts the contents.xml contents
  # of an ODF document
  def test_extracts_contents_from_odf_file
    contents = Documentalist::ODFMerge.get_contents(@@odf_file)

    assert_match /Hello/, contents
    assert_match /thing/, contents
    assert !(contents =~ /%&gt;/)
    assert !(contents =~ /&lt;%=/)
  end

  # Tests that a merge is correctly performed with an ODF template
  def test_odf_merge
    result = File.join(Dir.tmpdir, "#{(rand * 10 ** 9).to_i}.odt")

    Documentalist.odf_merge @@odf_file,
      :locals => {:thing => "world"},
      :to => result

    assert /world/, Documentalist::ODFMerge.get_contents(result)

    FileUtils.rm result
    assert !File.exists?(result), "Oops, we haven't cleaned up our mess..."
  end

  # Tests that an ODF template can be merged and then converted to another format
  # using the OpenOffice backend
  def test_odf_merge_and_convert
    result = File.join(Dir.tmpdir, "#{(rand * 10 ** 9).to_i}.pdf")

    Documentalist.odf_merge @@odf_file,
      :locals => {:thing => "world"},
      :to => result

    assert File.exists?(result), "Seems like there is no merged result"

    FileUtils.rm result
    assert !File.exists?(result), "Oops, we haven't cleaned up our mess..."
  end
end
