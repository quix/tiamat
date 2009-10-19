require File.dirname(__FILE__) + '/tiamat_spec_base'

describe Tiamat::LocalChildFarm do
  before :all do
    @farm = Tiamat::LocalChildFarm.new(4, *Tiamat.compiler.reverse)
  end

  after :all do
    @farm.close
  end
    
  it "should provide local servers" do
    mod = pure(Pure::Parser::RubyParser) do
      def f
        33 + 44
      end
    end
    spec = Pure::ExtractedFunctions[Pure::Parser::RubyParser][mod][:f]

    20.times {
      @farm.lend_server { |server_a|
        @farm.lend_server { |server_b|
          server_a.evaluate_function(spec).should eql(77)
          server_b.evaluate_function(spec).should eql(77)
        }
      }
    }
  end
end
