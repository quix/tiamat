require File.dirname(__FILE__) + '/tiamat_spec_base'

describe Tiamat::RemoteWorker do
  before :each do
    @uris = (47055..47060).map { |n|
      "druby://localhost:#{n}"
    }
    # pretend these servers were running beforehand
    @servers = @uris.map { |uri|
      Tiamat::LocalChildServer.new(uri, *Tiamat.compiler.reverse)
    }
  end

  after :each do
    @servers.each { |server|
      server.close
    }
  end
  
  it "should compute without block" do
    Tiamat::RemoteWorker.open(*@uris)
    begin
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
      end.compute(Tiamat::RemoteWorker).f.should == 77
    ensure
      Tiamat::RemoteWorker.close
    end
  end

  it "should compute with block" do
    Tiamat::RemoteWorker.open(*@uris) do
      Pure.worker.object_id.should eql(Tiamat::RemoteWorker.object_id)
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
      end.compute.f.should == 77
    end
  end
end
