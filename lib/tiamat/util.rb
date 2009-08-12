
module Tiamat
  module Util
    module_function

    def ruby_executable
      require 'rbconfig'
      name = File.join(
        Config::CONFIG["bindir"],
        Config::CONFIG["RUBY_INSTALL_NAME"]
      )
      if Config::CONFIG["host"] =~ %r!(mswin|cygwin|mingw)! and
          File.basename(name) !~ %r!\.(exe|com|bat|cmd)\Z!i
        name + Config::CONFIG["EXEEXT"]
      else
        name
      end
    end

    def run_ruby(*args)
      cmd = [ruby_executable, *args]
      unless system(*cmd)
        raise RunRubyError.new(cmd, $?.exitstatus)
      end
    end

    def find_executable(basename)
      ENV["PATH"].split(File::PATH_SEPARATOR).each { |path|
        candidate = path + "/" + basename
        if File.exist?(candidate)
          return candidate
        end
      }
      nil
    end
  end
end
