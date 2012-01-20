# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "expression_processor/version"

Gem::Specification.new do |s|
  s.name        = "expression_processor"
  s.version     = ExpressionProcessor::VERSION
  s.authors     = ["Stephen St. Martin"]
  s.email       = ["kuprishuz@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Simple excel like formula processor}
  s.description = %q{Allows you to process simple excel like formulas.}

  s.rubyforge_project = "expression_processor"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
