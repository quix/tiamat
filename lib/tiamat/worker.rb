
module Tiamat
  class Worker
    def define_function_begin(pure_module, num_parallel)
    end
        
    def define_function(spec)
      lambda { |*args|
        self.class.farm.lend_server { |server|
          server.evaluate_function(spec, *args)
        }
      }
    end
        
    def define_function_end
    end

    def num_parallel
      self.class.num_parallel
    end
        
    class << self
      attr_reader :farm

      def open(farm)
        unless closed?
          raise AlreadyOpenError.new(self)
        end
        @farm = farm
        if block_given?
          previous_worker = Pure.worker
          Pure.worker = self
          begin
            yield
          ensure
            Pure.worker = previous_worker
            close
          end
        end
      end

      def close
        unless closed?
          @farm.close
          @farm = nil
        end
      end

      def closed?
        not defined?(@farm) or @farm.nil?
      end
    
      def num_parallel
        @farm.num_servers
      end

      def num_parallel=(value)
      end
    end
  end
end
