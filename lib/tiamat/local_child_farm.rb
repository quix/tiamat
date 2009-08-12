
module Tiamat
  class LocalChildFarm < Farm
    def initialize(num_servers, *args)
      base_uri = self.class.base_uri
      port_begin = self.class.port_begin
      servers = (0...num_servers).map { |n|
        LocalChildServer.new("#{base_uri}:#{port_begin + n}", *args)
      }
      super(servers)
    end
    
    class << self
      def base_uri
        "druby://localhost"
      end

      def port_begin
        # /etc/services: 24554-34676 Unassigned
        24676
      end
    end
  end
end
