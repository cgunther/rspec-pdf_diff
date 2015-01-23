require 'cocaine'

module RSpec
  module PDFDiff
    class MatchOriginalMatcher

      def initialize(name)
        @name = name
      end

      def matches?(path_to_result_pdf)
        if File.exist?(path_to_original_pdf)
          FileUtils.mkdir_p("tmp/#{name}")

          # Convert original to PNG
          convert_command.run(
            in: path_to_original_pdf,
            out: path_to_original_image
          )

          # Convert result to PNG
          convert_command.run(
            in: path_to_result_pdf,
            out: path_to_result_image
          )

          all_matched = true

          Dir.glob(path_to_result_image.gsub('.png', '') + '*').each do |result_image|
            if /\-(\d)+\.png\z/ =~ result_image
              page = $1
            end

            original_image = path_to_original_image(page)

            # Compare images
            diff_image = path_to_diff_image(page)

            FileUtils.mkdir_p(File.dirname(diff_image))

            compare_command.run(
              original: original_image,
              result: result_image,
              difference: diff_image
            )

            # compare returns 0 on match, 1 on different
            all_matched &= (compare_command.exit_status == 0)
          end

          # TODO: Clean up result/diff images that matched the original

          all_matched
        else
          # No original was saved, accepting by default

          # TODO: If it's the first page, we can probably assume it's the first
          # run and just accept it, but if it's an inner page, we should probably
          # fail as it'd be a new page we weren't expecting.

          # Make the result the original
          FileUtils.mkdir_p(File.dirname(path_to_original_pdf))
          FileUtils.mv path_to_result_pdf, path_to_original_pdf
        end
      end

      def failure_message
        # TODO: State which pages didn't match and give paths to the original,
        # result, and diff
        <<-EOS
          Expected that result would match original, but it did not.

          If the result is correct, delete the existing original and re-run the
          test to make the result the new original.
        EOS
      end

      private

      attr_reader :name

      def convert_command
        @convert_command ||= Cocaine::CommandLine.new(
          'convert',
          ':in :out'
        )
      end

      def compare_command
        @compare_command ||= Cocaine::CommandLine.new(
          'compare',
          # Get the absolute error count of the two images
          # (number of different pixels)
          '-metric AE :original :result :difference',
          # compare returns 0 on match, 1 on different
          expected_outcodes: [0, 1],
          swallow_stderr: true,
        )
      end

      def path_to_original_pdf
        Pathname.new('spec/support/originals').join("#{name}.pdf").to_s
      end

      def path_to_original_image(page = nil)
        filename = 'original'
        if page
          filename += "-#{page}"
        end

        Pathname.new('tmp').join(name, "#{filename}.png").to_s
      end

      def path_to_result_image
        Pathname.new('tmp').join(name, 'result.png').to_s
      end

      def path_to_diff_image(page)
        filename = 'diff'
        if page
          filename += "-#{page}"
        end

        Pathname.new('tmp').join(name, "#{filename}.png").to_s
      end

    end

    def match_original(*args)
      MatchOriginalMatcher.new(*args)
    end
  end
end
