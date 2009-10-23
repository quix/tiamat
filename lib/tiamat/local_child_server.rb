
module Tiamat
  class LocalChildServer < ChildServer
    def launch(uri, compiler_name, *requires)
      args = [compiler_name] + requires
      Util.run_ruby(self.class.server_path, uri, *args)
    end

    class << self
      def server_basename
        "tiamat-server"
      end

      def server_path
        if server = Util.find_executable(server_basename)
          server
        else
          File.expand_path(
            File.dirname(__FILE__) + "/../../bin/" + server_basename
          )
        end
      end
    end
  end
end
