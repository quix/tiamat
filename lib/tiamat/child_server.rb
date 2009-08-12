
module Tiamat
  class ChildServer < Server
    def initialize(uri, *args)
      @thread = Thread.new {
        launch(uri, *args)
      }
      super(uri)
    end
    
    def close
      begin
        @drb_object.close
      rescue DRb::DRbConnError
        nil # rcov workaround
      end
      super
      @thread.join
    end
  end
end
