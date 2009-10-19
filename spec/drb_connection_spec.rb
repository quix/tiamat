require File.dirname(__FILE__) + '/tiamat_spec_base'

describe "drb connection" do
  before :all do
    @uri = "druby://localhost:22334"
    @server = Tiamat::LocalChildServer.new(@uri, *Tiamat.compiler.reverse)
  end

  after :all do
    @server.close
  end

  it "should be creatable" do
    @server.instance_eval do
      @drb_object.ping
    end
  end
end
