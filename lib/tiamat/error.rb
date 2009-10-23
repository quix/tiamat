
module Tiamat
  class Error < StandardError
  end

  class AlreadyOpenError < Error
    def initialize(object)
      @object = object
      super("open called on object which is already open: #{@object.inspect}")
    end

    attr_reader :object
  end

  class RunRubyError < Error
    def initialize(command, status)
      @command, @status = command, status
      command_str = command.map { |a| "'#{a}'" }.join(", ")
      super("system(#{command_str}) failed with status #{@status}")
    end

    attr_reader :command, :status
  end
end
