
module Tiamat
  class << self
    #
    # Launch _num_parallel_ local Ruby interpreters.
    #
    # If a block is given:
    # * Pure.worker is replaced for the duration of the block.
    # * The return value is the block result.
    # * The interpreters are stopped when the block finishes.
    #
    # If no block is given, an opened worker is returned. You are
    # responsible for closing it.
    #
    def open_local(num_parallel, *requires, &block)
      args = [num_parallel] + Tiamat.compiler.reverse + requires
      open_worker(LocalChildWorker, *args, &block)
    end

    #
    # Connect to the already-running tiamat servers given by the URIs,
    # e.g. druby://192.168.4.1:27272.
    #
    # If a block is given:
    # * Pure.worker is replaced for the duration of the block.
    # * The return value is the block result.
    #
    # If no block is given, an opened worker is returned. You are
    # responsible for closing it.
    #
    def open_remote(*uris, &block)
      open_worker(RemoteWorker, *uris, &block)
    end
    
    attr_accessor :compiler

    private
    
    def open_worker(worker, *args, &block)
      result = worker.open(*args, &block)
      if block
        result
      else
        worker
      end
    end
  end
  @compiler = nil
end
