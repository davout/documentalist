require 'test/unit'
require 'officer'

class OfficerTest < Test::Unit::TestCase
  @@odt_fixture = File.join(File.dirname(__FILE__), "fixtures/fixture.odt")

  def test_merge
    template = "<%= @var1 %><%= 1.upto(3).map{ |n| n.to_s }.join %><%= @var2 %>"

    merged = Officer.merge(template, :locals => {
        :var1 => "test",
        :var2 => "working?"
      }
    )

    assert_equal "test123working?", merged, "Merge wasn't performed correctly"
  end

  def test_read_zipped_odt
    contents = Officer.get_contents(@@odt_fixture)

    assert_match /Hello/, contents
    assert_match /thing/, contents
    assert !(contents =~ /%&gt;/)
    assert !(contents =~ /&lt;%=/)
  end

  def test_odt_merge
    template = "#{File.join(File.dirname(__FILE__), "fixtures/fixture.odt")}"
    result = "#{File.join(File.dirname(__FILE__), "fixtures/result.odt")}"

    Officer.merge_template(template,
      :locals => {:thing => "world"},
      :to => result
    )
    
    assert /world/, Officer.get_contents(result)
    File.delete(result)
  end
end
