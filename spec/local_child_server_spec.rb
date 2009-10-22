require File.dirname(__FILE__) + '/tiamat_spec_base'

describe Tiamat::LocalChildServer do
  before :all do
    @server = Tiamat::LocalChildServer.new(
      "druby://localhost:27272", *Tiamat.compiler.reverse
    )
  end

  after :all do
    @server.close
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
end
