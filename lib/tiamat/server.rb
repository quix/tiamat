
module Tiamat
  class Server
    include Connector

    def initialize(uri)
      @uri = uri
      @drb_object = DRbObject.new_with_uri(uri)
      connect {
        @drb_object.ping
      }
    end

    attr_reader :uri

    def close
      connection.close
    rescue DRb::DRbConnError
    end

    def evaluate_function(*args)
      @drb_object.evaluate_function(*args)
    end

    private

    def connect(&block)
      super(self.class.wait_interval, self.class.timeout, &block)
    end

    def connection
      result = nil
      DRb::DRbConn.open(@uri) { |conn|
        result = conn
      }
      result
    end

    class << self
      attr_writer :wait_interval
      attr_writer :timeout

      def wait_interval
        @wait_interval ||= 0.02
      end

      def timeout
        @timeout ||= 3
      end
    end
  end
end
