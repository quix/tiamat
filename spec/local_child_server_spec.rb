require File.dirname(__FILE__) + '/tiamat_spec_base'

describe Tiamat::LocalChildServer do
  before :all do
    @server = Tiamat::LocalChildServer.new(
      "druby://localhost:27272", *Tiamat.compiler
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

  describe "" do
    before :all do
      require 'fileutils'
      @dummy_server = File.expand_path(
        File.dirname(__FILE__) +
        "/data/" + 
        Tiamat::LocalChildServer.server_basename
      )
      FileUtils.mkdir_p(File.dirname(@dummy_server))
      FileUtils.touch(@dummy_server)
    end
    
    after :all do
      FileUtils.rm_r(File.dirname(@dummy_server))
    end

    it "should prefer #{Tiamat::LocalChildServer.server_basename} in path" do
      new_path = (
        ENV["PATH"].
        split(File::PATH_SEPARATOR).
        unshift(File.dirname(@dummy_server))
      ).join(File::PATH_SEPARATOR)

      fallback = File.expand_path(
        File.dirname(__FILE__) +
        "/../bin/" +
        Tiamat::LocalChildServer.server_basename
      )
      Tiamat::LocalChildServer.server_path.should eql(fallback)
      with_env("PATH" => new_path) {
        Tiamat::LocalChildServer.server_path.should eql(@dummy_server)
      }
      Tiamat::LocalChildServer.server_path.should eql(fallback)
    end
  end
end
