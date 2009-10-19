require File.dirname(__FILE__) + '/tiamat_spec_base'

require 'tiamat/tiamat_server'

describe Tiamat::TiamatServer do
  before :all do
    @server = Tiamat::TiamatServer.new(
      Tiamat::VERSION, *Tiamat.compiler.reverse
    )
  end

  it "should evaluate a pure function spec" do
    mod = pure do
      def f
        33 + 44
      end
    end
    spec = Pure::ExtractedFunctions[Pure.parser][mod][:f]
    @server.evaluate_function(spec).should == 77
  end

  it "should handle `fun' definitions with no args" do
    mod = pure do
      fun :f do
        33 + 44
      end
    end
    spec = Pure::ExtractedFunctions[Pure.parser][mod][:f]
    @server.evaluate_function(spec).should == 77
  end

  it "should handle `fun' definitions with args" do
    mod = pure do
      fun :f => [:x, :y] do |u, v|
        u*v
      end
    end
    spec = Pure::ExtractedFunctions[Pure.parser][mod][:f]
    @server.evaluate_function(spec, 4, 5).should == 20
  end

  it "should raise error when version doesn't match" do
    message = "expected version #{Tiamat::VERSION}, got 0.0.0"
    lambda {
      Tiamat::TiamatServer.new("0.0.0", *Tiamat.compiler.reverse)
    }.should raise_error(Tiamat::VersionError, message)

    Tiamat::VersionError.
    new(Tiamat::VERSION, "0.0.0").
    inspect.should match(message)
  end

  it "should run" do
    uri = "druby://localhost:27272"
    thread = Thread.new {
      Tiamat::TiamatServer.run(uri, Tiamat::VERSION, *Tiamat.compiler.reverse)
    }
    Tiamat::Server.new(uri).instance_eval {
      @drb_object.ping
      @drb_object.close
    }
    thread.join
  end
end
