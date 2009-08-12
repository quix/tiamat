
module Tiamat
  class Error < StandardError
  end

  class VersionError < Error
    def initialize(expected, actual)
      @expected, @actual = expected, actual
      super("expected version #{@expected}, got #{@actual}")
    end

    attr_reader :expected, :actual
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
