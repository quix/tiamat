require File.dirname(__FILE__) + '/tiamat_spec_base'

describe Tiamat::RemoteFarm do
  before :all do
    uris = (47055..47060).map { |n|
      "druby://localhost:#{n}"
    }
    @servers = uris.map { |uri|
      Tiamat::LocalChildServer.new(uri, *Tiamat.compiler)
    }
    @farm = Tiamat::RemoteFarm.new(*uris)
    Tiamat::Worker.open(@farm)
  end
  
  after :all do
    Tiamat::Worker.close
    @farm.close
    @servers.each { |s| s.close }
  end
  
  it "should be useable by a worker" do
    pure(Pure::Parser::RubyParser) do
      def f(x, y)
        x + y
      end
      
      def x
        33
      end
      
      def y
        44
      end
    end.compute(Tiamat::Worker).f.should == 77
  end
end
