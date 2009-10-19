require File.dirname(__FILE__) + '/tiamat_spec_base'

describe Tiamat::Server do
  before :all do
    @url = "druby://localhost:27272"
    @remote_server = Tiamat::LocalChildServer.new(
      @url, *Tiamat.compiler.reverse
    )
    @server = Tiamat::Server.new(@url)
  end

  after :all do
    @remote_server.close
    @server.close
  end

  it "should connect to remote server" do
    @server.instance_eval {
      @drb_object.ping
    }
  end

  it "should evaluate a pure function spec" do
    mod = pure(Pure::Parser::RubyParser) do
      def f
        33 + 44
      end
    end
    spec = Pure::ExtractedFunctions[Pure::Parser::RubyParser][mod][:f]
    
    @server.evaluate_function(spec).should == 77
  end

  it "should fail with undumpable objects by default" do
    DRb.primary_server.should be_nil

    lambda {
      @server.evaluate_function(STDOUT)
    }.should raise_error(DRb::DRbConnError, %r!DRbServerNotFound!)
  end

  it "should ignore subsequent calls to close()" do
    lambda {
      @server.close
      @server.close
    }.should_not raise_error
  end
end
