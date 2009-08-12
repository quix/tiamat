
module Tiamat
  class Farm
    def initialize(servers)
      @servers = servers
      @available = Queue.new

      @servers.each { |server|
        @available.push(server)
      }
    end

    def num_servers
      @servers.size
    end

    def lend_server
      server = @available.pop
      begin
        yield server
      ensure
        @available.push(server)
      end
    end

    def close
      @servers.each { |server|
        server.close
      }
    end
  end
end
