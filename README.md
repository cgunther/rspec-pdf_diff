# RSpec::PDFDiff

Provides a matcher for testing that a generated PDF visually matches a saved, known-good PDF.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-pdf_diff'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-pdf_diff

Both [ImageMagick](http://www.imagemagick.org/) and
[Ghostscript](http://www.ghostscript.com/) must be installed on the system.

## Usage

Generate your PDF to a file, then call the `match_original` matcher on the
path:

```ruby
tmp = Tempfile.new(['document', '.pdf'])
begin
  # Assuming my_document is an instance of a Prawn::Document
  my_document.render_file(tmp.path)

  expect(tmp.path).to match_original
ensure
  tmp.unlink
end

```

On your first run, since no original is stored yet, we'll just store the
generated result as the accepted original. Then on future test runs, the test
will fail unless the generated result matches the stored original exactly.

The originals will be stored in `spec/support/originals` and should be
committed to version control. If the generated result does not match the
original, the generated result will be moved to the `tmp` folder as well as an
overlaid reconstructed image of each page, highlighting the pixels that differ
between the original and the result.

## Contributing

1. Fork it ( https://github.com/cgunther/rspec-pdf_diff/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
