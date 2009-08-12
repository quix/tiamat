
module Tiamat
  class RemoteFarm < Farm
    def initialize(*uris)
      servers = uris.map { |uri|
        Server.new(uri)
      }
      super(servers)
    end
  end
end
