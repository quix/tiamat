require File.dirname(__FILE__) + '/tiamat_spec_base'

require "jumpstart"

readme = "README.rdoc"

Jumpstart.doc_to_spec(readme, "Synopsis") {
  |expected_str, actual_str, index|

  expected, actual = [expected_str, actual_str].map { |expr|
    expr.should match(%r!\A\d+\.\d+\n\d+\.\d+\Z!)
    expr.split.map { |s| s.to_f }
  }.map { |pair|
    {
      :one_cpu => pair[0],
      :two_cpu => pair[1],
    }
  }

  [expected, actual].each { |result|
    (result[:two_cpu]/result[:one_cpu]).should be_close(0.5, 0.15)
  }
}

Jumpstart.doc_to_spec(readme, "Adding +require+ Paths to Local Servers")

Jumpstart.doc_to_spec(readme, "About DRbConnError")

