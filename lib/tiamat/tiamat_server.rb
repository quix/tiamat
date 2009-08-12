#
# This is the core of bin/tiamat-server, the code which runs on the
# remote Ruby interpreter.
#
# This file is not required by the top-level tiamat.rb.
#

module Tiamat
  class TiamatServer
    FINISH = Queue.new

    def initialize(version, compiler_name, *requires)
      unless version == Tiamat::VERSION
        raise VersionError.new(Tiamat::VERSION, version)
      end

      @compiler_name = compiler_name

      requires.each { |path| require path }

      @compiler = compiler_name.split("::").inject(Object) { |acc, name|
        acc.const_get(name)
      }.new

      nil # rcov workaround
    end

    attr_reader :compiler_name

    def evaluate_function(spec, *args)
      @compiler.evaluate_function(spec, *args)
    end

    def ping
    end

    def close
      FINISH.push nil
    end

    class << self
      def run(uri, *args)
        DRb.start_service(uri, new(*args))
        FINISH.pop
      end
    end
  end
end
