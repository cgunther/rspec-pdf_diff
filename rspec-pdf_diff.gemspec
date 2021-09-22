# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/pdf_diff/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-pdf_diff"
  spec.version       = RSpec::PDFDiff::VERSION
  spec.authors       = ["Chris Gunther"]
  spec.email         = ["chris@room118solutions.com"]
  spec.summary       = 'RSpec matcher for testing generation of PDF files'
  spec.description   = 'Compare generated PDF to a saved PDF to ensure they are visually identical, or view the differences between them'
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "terrapin", "~> 0.5"

  spec.add_development_dependency "prawn", "~> 1.3.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
