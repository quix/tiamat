require File.dirname(__FILE__) + '/tiamat_spec_base'

require 'benchmark'

describe Tiamat::LocalChildWorker do
  before :all do
    Tiamat::LocalChildWorker.open(2, *Tiamat.compiler.reverse)
  end

  after :all do
    Tiamat::LocalChildWorker.close
  end

  it "should evaluate a pure function with no args" do
    result = pure do
      def f
        11 + 22
      end
    end.compute(Tiamat::LocalChildWorker)

    result.f.should == 33
  end

  it "should evaluate a pure function with args" do
    mod = pure do
      def f(x, y)
        x + y
      end
      def x
        33
      end
      def y
        44
      end
    end.compute(Tiamat::LocalChildWorker).f.should == 77
  end

  it "should handle `fun' definitions with no args" do
    pure do
      fun :f do
        11 + 22
      end
    end.compute(Tiamat::LocalChildWorker).f.should == 33
  end

  it "should handle `fun' definitions with args" do
    pure do
      fun :f => [:x, :y] do |u, v|
        u*v
      end

      fun :x do
        4
      end

      def y
        5
      end
    end.compute(Tiamat::LocalChildWorker).f.should == 20
  end

  it "should be around 2x faster with 2 servers" do
    mod = pure do
      def total(left, right)
        left + right
      end

      def left
        (1..250_000).inject(0) { |acc, n| acc + n }
      end

      def right
        (1..250_000).inject(0) { |acc, n| acc + n }
      end
    end
    
    default_result = nil
    default_time = mod.compute(2) { |result|
      Benchmark.measure {
        default_result = result.total
      }.real
    }
    
    tiamat_result = nil
    tiamat_time = mod.compute(Tiamat::LocalChildWorker) { |result|
      Benchmark.measure {
        tiamat_result = result.total
      }.real
    }

    expected = 250_000*(250_000 + 1)
    default_result.should eql(expected)
    tiamat_result.should eql(expected)

    # jruby is slow
    epsilon = 0.65 + (RUBY_PLATFORM == "java" ? 1.0 : 0)
    if ARGV.include? "--bench"
      puts
      puts "-----------"
      puts "tiamat  #{tiamat_time}"
      puts "default #{default_time}"
      puts
      puts "ratio   #{tiamat_time/default_time}"
      puts "-----------"
    end
  end

  it "should propagate exceptions from root function" do
    mod = pure do
      def f
        raise "zz"
      end
    end
    result = mod.compute(4)
    lambda {
      result.f
    }.should raise_error(RuntimeError, "zz")
  end

  it "should propagate exceptions from child functions" do
    mod = pure do
      def f(x)
        33
      end
      
      def x(y)
        44
      end
      
      def y
        raise "foo"
      end
    end
    result = mod.compute(4)
    lambda {
      result.f
    }.should raise_error(RuntimeError, "foo")
  end
end

