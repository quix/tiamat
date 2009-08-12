
module Tiamat
  module Connector
    module_function

    def connect(wait_interval, timeout)
      begin
        yield
      rescue DRb::DRbConnError
        start = Time.now
        begin
          Kernel.sleep(wait_interval)
          yield
        rescue DRb::DRbConnError
          if Time.now - start > timeout
            raise
          end
          retry
        end
      end
    end
  end
end
