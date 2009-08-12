
module Tiamat
  class LocalChildWorker < Worker
    class << self
      def open(num_servers, *args, &block)
        farm = LocalChildFarm.new(num_servers, *args)
        super(farm, &block)
      end
    end
  end
end
