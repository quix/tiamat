
module Tiamat
  class << self
    #
    # Launch _num_parallel_ local Ruby interpreters.
    #
    # Pure.worker will be assigned to a Tiamat-specific worker.
    #
    # If a block is given, the interpreters will be stopped when the
    # block finishes and the previous Pure.worker will be restored.
    #
    # Each interpreter will +require+ the paths in _requires_.
    #
    def open_local(num_parallel, *requires, &block)
      args = [num_parallel] + Tiamat.compiler + requires
      open_worker(LocalChildWorker, *args, &block)
    end

    #
    # Close the worker opened by +open_local+.  Assigns Pure.worker
    # back to the default worker, Pure::NativeWorker.
    #
    def close_local
      close_worker(LocalChildWorker)
    end

    #
    # Connect to the already-running tiamat servers given by the URIs,
    # e.g. druby://192.168.4.1:27272.
    #
    # Pure.worker will be assigned to a Tiamat-specific worker.
    #
    # If a block is given, the previous Pure.worker will be restored
    # when the block finishes.
    #
    def open_remote(*uris, &block)
      open_worker(RemoteWorker, *uris, &block)
    end
    
    #
    # Close the worker opened by +open_remote+.  Assigns Pure.worker
    # back to the default worker, Pure::NativeWorker.
    #
    def close_remote
      close_worker(RemoteWorker)
    end

    attr_accessor :compiler

    private
    
    def open_worker(worker, *args, &block)
      result = worker.open(*args, &block)
      unless block
        Pure.worker = worker
      end
      result
    end
    
    def close_worker(worker, *args, &block)
      worker.close
      Pure.worker = Pure::NativeWorker
    end
  end
  @compiler = nil
end
