require File.dirname(__FILE__) + '/tiamat_spec_base'

require 'benchmark'

epsilon = 0.25 + TiamatSpecBase.slow_platform_epsilon

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

  describe ".open_remote" do
    before :all do
      @uris = (47055..47060).map { |n|
        "druby://localhost:#{n}"
      }
      @servers = @uris.map { |uri|
        Tiamat::LocalChildServer.new(uri, *Tiamat.compiler.reverse)
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
        (two_cpu/one_cpu).should be_close(0.5, epsilon)
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
          (two_cpu/one_cpu).should be_close(0.5, epsilon)
        ensure
          Pure.worker.close
          Pure.worker = Pure::NativeWorker
        end
        Tiamat::RemoteWorker.closed?.should eql(true)
      end
    end
  end
end
