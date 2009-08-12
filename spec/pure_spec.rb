require File.dirname(__FILE__) + '/tiamat_spec_base'

describe Pure do
  before :all do
    border = pure do
      def border
        2
      end
    end

    @geometry = pure do
      include border

      def area(width, height)
        width*height
      end
      
      def width(border)
        7 + border
      end
      
      def height(border)
        5 + border
      end
    end
  end

  it "should use the custom worker assigned to Pure.worker" do
    expected = {
      :area => [:width, :height],
      :width => [:border],
      :height => [:border],
      :border => [],
    }

    actual = Hash.new

    worker = Class.new do
      def num_parallel
        2
      end

      def define_function_begin(*args)
      end
      
      def define_function_end(*args)
      end

      define_method :define_function do |spec|
        lambda { |*a|
          actual[spec[:name]] = spec[:args]
        }
      end
    end

    @geometry.compute(worker).area
    actual.should == expected
  end
end
