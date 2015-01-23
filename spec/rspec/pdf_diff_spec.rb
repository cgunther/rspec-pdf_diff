require 'spec_helper'
require 'tempfile'
require 'prawn'

RSpec.describe RSpec::PDFDiff do
  after do
    # Clean up after ourselves
    FileUtils.rm_r 'spec/support/originals' if Dir.exist?('spec/support/originals')
    FileUtils.rm_r 'tmp' if Dir.exist?('tmp')
  end

  it 'stores the generated PDF when no original exists already' do
    tmp = Tempfile.new(['document', '.pdf'])
    begin
      Prawn::Document.generate(tmp.path) do
        text 'This is a test'
      end

      expect(Dir['spec/support/originals/**/*.png'].length).to eq(0)

      expect(tmp.path).to match_original('test')

      expect(Dir['spec/support/originals/**/*.png'].length).to eq(1)
    ensure
      tmp.unlink
    end
  end

  it 'matches when the generated PDF is identical to the stored PDF' do
    original = Tempfile.new(['original', '.pdf'])
    begin
      pdf = Prawn::Document.new do
        text 'This is a test'
      end
      pdf.render_file(original.path)

      # Quick way to store the PDF
      expect(original.path).to match_original('test')

      result = Tempfile.new(['result', '.pdf'])
      begin
        pdf.render_file(result.path)

        expect(result.path).to match_original('test')
      ensure
        result.unlink
      end
    ensure
      original.unlink
    end
  end

  it 'does not match when the generated PDF is different from the stored PDF and saves the result and diff' do
    original = Tempfile.new(['original', '.pdf'])
    begin
      Prawn::Document.generate(original.path) do
        text 'This is a test'
      end

      # Quick way to store the PDF
      expect(original.path).to match_original('test')

      result = Tempfile.new(['result', '.pdf'])
      begin
        Prawn::Document.generate(result.path) do
          text 'This is not a test'
        end

        expect(result.path).to_not match_original('test')

        expect(Dir['tmp/**/*.result-*.png'].length).to eq(1)
        expect(Dir['tmp/**/*.diff.png'].length).to eq(1)
      ensure
        result.unlink
      end
    ensure
      original.unlink
    end
  end
end
