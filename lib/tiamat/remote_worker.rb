
module Tiamat
  class RemoteWorker < Worker
    class << self
      def open(*uris, &block)
        super(RemoteFarm.new(*uris), &block)
      end
    end
  end
end
