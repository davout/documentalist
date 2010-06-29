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
#
#  def test_read_zipped_odt
#    contents = Documentalist.get_contents(@@odt_fixture)
#
#    assert_match /Hello/, contents
#    assert_match /thing/, contents
#    assert !(contents =~ /%&gt;/)
#    assert !(contents =~ /&lt;%=/)
#  end
#
#  def test_odt_merge
#    template = "#{File.join(File.dirname(__FILE__), "fixtures/fixture.odt")}"
#    result = "#{File.join(File.dirname(__FILE__), "fixtures/result.odt")}"
#
#    Documentalist.merge_template(template,
#      :locals => {:thing => "world"},
#      :to => result
#    )
#
#    assert /world/, Documentalist.get_contents(result)
#    File.delete(result)
#  end
#
#  def test_timeout_uses_system_timeout
#    assert false, "Implement me"
#
#    # timeout should work with long system call, only if system timer is used
#    # tho, it should be checked moar in case default timeout handles it well
#  end
end
