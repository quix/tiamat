require File.dirname(__FILE__) + '/tiamat_spec_base'

require 'benchmark'

describe Tiamat do
  before :all do
    @mod = Pure.define do
      def total(left, right)
        left + right
      end
      def left
        (1..100_000).inject(0) { |acc, n| acc + n }
      end
      def right
        (1..100_000).inject(0) { |acc, n| acc + n }
      end
    end
  end

  describe ".open_local" do
    describe "with block" do
      it "should launch local servers" do
        one_cpu = Benchmark.realtime { @mod.compute(2).total }
        two_cpu = Tiamat.open_local(2) {
          Pure.worker.should eql(Tiamat::LocalChildWorker)
          Pure.worker.closed?.should eql(false)
          Benchmark.realtime { @mod.compute.total }
        }
        (two_cpu/one_cpu).should be_close(0.5, 0.25)
        Tiamat::LocalChildWorker.closed?.should eql(true)
      end
    end

    describe "without block" do
      it "should launch local servers" do
        one_cpu = Benchmark.realtime { @mod.compute(2).total }
        Pure.worker = Tiamat.open_local(2)
        begin
          Pure.worker.should eql(Tiamat::LocalChildWorker)
          Pure.worker.closed?.should eql(false)
          two_cpu = Benchmark.realtime { @mod.compute.total }
          (two_cpu/one_cpu).should be_close(0.5, 0.25)
        ensure
          Pure.worker.close
          Pure.worker = Pure::NativeWorker
        end
        Tiamat::LocalChildWorker.closed?.should eql(true)
      end
    end

    it "should accept require list" do
      mod = pure do
        def f(s)
          Base64.encode64(Matrix[[s]][0, 0])
        end
      end
        
      Tiamat.open_local(1) {
        lambda {
          mod.compute(:s => "abc").f
        }.should raise_error(NameError, %r!Base64!)
      }
      
      Tiamat.open_local(1, 'base64') {
        lambda {
          mod.compute(:s => "abc").f
        }.should raise_error(NameError, %r!Matrix!)
      }
      
      Tiamat.open_local(1, 'base64', 'matrix') {
        mod.compute(:s => "abc").f.should == "YWJj\n"
      }
    end
  end

  describe ".open_remote" do
    before :all do
      @uris = (47055..47060).map { |n|
        "druby://localhost:#{n}"
      }
      @servers = @uris.map { |uri|
        Tiamat::LocalChildServer.new(uri, *Tiamat.compiler)
      }
    end
    
    after :all do
      @servers.each { |t| t.close }
      Tiamat::RemoteWorker.close
    end

    describe "with block" do
      it "should connect to remote servers" do
        one_cpu = Benchmark.realtime { @mod.compute(2).total }
        two_cpu = Tiamat.open_remote(*@uris) {
          Pure.worker.should eql(Tiamat::RemoteWorker)
          Pure.worker.closed?.should eql(false)
          Benchmark.realtime { @mod.compute.total }
        }
        (two_cpu/one_cpu).should be_close(0.5, 0.25)
        Tiamat::RemoteWorker.closed?.should eql(true)
      end
    end

    describe "without block" do
      it "should connect to remote servers" do
        one_cpu = Benchmark.realtime { @mod.compute(2).total }
        Pure.worker = Tiamat.open_remote(*@uris)
        begin
          Pure.worker.should eql(Tiamat::RemoteWorker)
          Pure.worker.closed?.should eql(false)
          two_cpu = Benchmark.realtime { @mod.compute.total }
          (two_cpu/one_cpu).should be_close(0.5, 0.25)
        ensure
          Pure.worker.close
          Pure.worker = Pure::NativeWorker
        end
        Tiamat::RemoteWorker.closed?.should eql(true)
      end
    end
  end
end
