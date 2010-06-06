require 'test/unit'
require 'officer'

class OfficerTest < Test::Unit::TestCase
  def test_merge
    template = "<%= @instance_var %><%= 1.upto(3).map{ |n| n.to_s }.join %>{{variable}}>"

    @instance_var = "test"

    merged = Officer.merge(template, {:variable => "working?"})

    assert_equal "test123working?", merged, "Merge wasn't performed correctly"
  end
end
