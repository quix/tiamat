require File.dirname(__FILE__) + '/tiamat_spec_base'

describe Tiamat::Worker do
  it "should raise when open() called while open" do
    count = 0
    mock_farm = Class.new do
      define_method :close do
        count += 1
      end
    end.new
    lambda {
      Tiamat::Worker.open(mock_farm) do
        Tiamat::Worker.open(mock_farm) do
        end
      end
    }.should raise_error(Tiamat::AlreadyOpenError, %r!already open!)
    count.should == 1
  end
end
