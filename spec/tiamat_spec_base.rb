$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../devel"

require 'pure/dsl'
require 'tiamat/autoconfig'
require 'spec/autorun'

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
