require "rspec/pdf_diff/matcher"
require "rspec/pdf_diff/version"

RSpec.configure do |config|
  config.include RSpec::PDFDiff
end
