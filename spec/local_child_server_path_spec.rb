require File.dirname(__FILE__) + '/tiamat_spec_base'

describe "Tiamat::LocalChildServer launch" do
  before :all do
    require 'fileutils'
    @dummy_server = File.expand_path(
      File.dirname(__FILE__) +
      "/data/" + 
      Tiamat::LocalChildServer.server_basename
    )
    FileUtils.mkdir_p(File.dirname(@dummy_server))
    FileUtils.touch(@dummy_server)
  end
    
  after :all do
    FileUtils.rm_r(File.dirname(@dummy_server))
  end

  it "should prefer #{Tiamat::LocalChildServer.server_basename} in path" do
    new_path = (
      ENV["PATH"].
      split(File::PATH_SEPARATOR).
      unshift(File.dirname(@dummy_server))
    ).join(File::PATH_SEPARATOR)

    fallback = File.expand_path(
      File.dirname(__FILE__) +
      "/../bin/" +
      Tiamat::LocalChildServer.server_basename
    )
    Tiamat::LocalChildServer.server_path.should eql(fallback)
    TiamatSpecBase.with_env("PATH" => new_path) {
      Tiamat::LocalChildServer.server_path.should eql(@dummy_server)
    }
    Tiamat::LocalChildServer.server_path.should eql(fallback)
  end
end
