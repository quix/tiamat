$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../devel"

require 'rubygems'
require 'pure/dsl'
require 'tiamat/autoconfig'
require 'spec/autorun'

# for tiamat-server requires
ENV["RUBYLIB"] = (
  lib = File.dirname(__FILE__) + "/../lib"
  if ENV["RUBYLIB"].nil?
    lib
  else
    sep = File::PATH_SEPARATOR
    ([lib] + ENV["RUBYLIB"].split(sep)).join(sep)
  end
)

def with_env(hash)
  previous_env = ENV.inject(Hash.new) { |acc, (key, value)|
    acc.merge!(key => value)
  }
  hash.each_pair { |key, value|
    ENV[key] = value
  }
  begin
    yield
  ensure
    ENV.clear
    previous_env.each_pair { |key, value|
      ENV[key] = value
    }
  end
end
