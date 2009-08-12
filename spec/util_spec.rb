require File.dirname(__FILE__) + '/tiamat_spec_base'

# rcov hack
describe Tiamat::Util do
  describe ".run_ruby" do
    it "should pass rcov butchery" do
      previous_host = Config::CONFIG["host"]
      previous_verbose = $VERBOSE
      $VERBOSE = nil
      begin
        Config::CONFIG["host"] = "mingw"
        load File.dirname(__FILE__) + "/../lib/tiamat/util.rb"
        lambda {
          Tiamat::Util.run_ruby("-e", "")
        }.should_not raise_error
      ensure
        Config::CONFIG["host"] = previous_host
        load File.dirname(__FILE__) + "/../lib/tiamat/util.rb"
        $VERBOSE = previous_verbose
      end
    end

    it "should raise when it fails" do
      lambda {
        Tiamat::Util.run_ruby("-e", "exit 99")
      }.should raise_error(Tiamat::RunRubyError, %r!failed with status 99!)
    end
  end
end
