require File.dirname(__FILE__) + '/tiamat_spec_base'

describe Tiamat::Connector do
  it "should raise for nonexistent server" do
    lambda {
      Tiamat::Connector.connect(0.1, 0.5) {
        DRbObject.new_with_uri("druby://localhost:9999").foo
      }
    }.should raise_error(DRb::DRbConnError)
  end
end
