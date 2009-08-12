require File.dirname(__FILE__) + '/tiamat_spec_base'

describe "drb connection" do
  before :all do
    @uri = "druby://localhost:22334"
    @server = Tiamat::LocalChildServer.new(@uri, *Tiamat.compiler)
  end

  after :all do
    @server.close
  end

  it "should be creatable" do
    @server.instance_eval do
      @drb_object.ping
    end
  end

  it "should be persistent" do
    connection = nil
    DRb::DRbConn.open(@uri) { |c| connection = c }
    connection.should_not be_nil

    connection_again = nil
    DRb::DRbConn.open(@uri) { |c| connection_again = c }
    connection_again.should_not be_nil

    connection.object_id.should == connection_again.object_id
  end

  it "should be closable" do
    connection = nil
    DRb::DRbConn.open(@uri) { |c| connection = c }
    connection.should_not be_nil

    connection_again = nil
    DRb::DRbConn.open(@uri) { |c| connection_again = c }
    connection_again.should_not be_nil

    connection.object_id.should eql(connection_again.object_id)

    connection_again.close
    DRb::DRbConn.open(@uri) { |c| connection_again = c }

    connection.object_id.should_not eql(connection_again.object_id)
  end

  it "should be closable from the remote end" do
    connection = nil
    DRb::DRbConn.open(@uri) { |c| connection = c }
    connection.should_not be_nil

    connection.alive?.should be_true

    @server.close
    connection.instance_eval { @protocol }.should be_nil
    connection.alive?.should be_false
  end
end
