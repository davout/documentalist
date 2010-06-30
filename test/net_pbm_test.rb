require 'test_helper'

class NetPBMTest < Test::Unit::TestCase
  def test_net_pbm_binary_is_present
    assert !`which ppmtojpeg`.empty?, "Can't seem to find ppmtojpeg binary"
  end
end
