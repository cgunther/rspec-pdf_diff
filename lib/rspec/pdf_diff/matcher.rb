require 'cocaine'

RSpec::Matchers.define :match_original do

  match do |path_to_result_pdf|
    # Convert result to PNG
    FileUtils.mkdir_p(File.dirname(path_to_result_image))

    Cocaine::CommandLine.new(
      'convert',
      ':in :out'
    ).run(
      in: path_to_result_pdf,
      out: path_to_result_image
    )

    if File.exist?(path_to_result_image)
      # It was only a 1 page PDF, so it used the output filename exactly.
      # Rename it to include a page number, so it's the same naming as a
      # multi-page PDF.
      FileUtils.mv path_to_result_image, path_to_result_image.gsub('.png', '-0.png')
    end

    all_matched = true

    Dir.glob(path_to_result_image.gsub('.png', '') + '-*').each do |result_image|
      page = /\-(\d)+\.png\z/.match(result_image)[1]

      original_image = path_to_original_image(page)

      if File.exist?(original_image)
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
      else
        # No original was saved, accepting by default

        # TODO: If it's the first page, we can probably assume it's the first
        # run and just accept it, but if it's an inner page, we should probably
        # fail as it'd be a new page we weren't expecting.

        # Make the result the original
        FileUtils.mkdir_p(File.dirname(original_image))
        FileUtils.mv result_image, original_image
      end
    end

    # TODO: Clean up result/diff images that matched the original

    all_matched
  end

  failure_message do
    # TODO: State which pages didn't match and give paths to the original,
    # result, and diff
    <<-EOS.strip_heredoc
      Expected that result would match original, but it did not.

      If the result is correct, delete the existing original and re-run the
      test to make the result the new original.
    EOS
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

  def path_to_original_image(page)
    Pathname.new('spec/support/originals').join(
      "#{sanitized_filename}-#{page}.png",
    ).to_s
  end

  def path_to_result_image
    Pathname.new('tmp').join(
      "#{sanitized_filename}.result.png",
    ).to_s
  end

  def path_to_diff_image(page)
    Pathname.new('tmp').join(
      "#{sanitized_filename}-#{page}.diff.png",
    ).to_s
  end

  def sanitized_filename
    filename_for(RSpec.current_example.metadata).gsub(/[^\w\-\/]+/, '_')
  end

  def filename_for(metadata)
    description = metadata[:description]
    example_group = if metadata.key?(:example_group)
      metadata[:example_group]
    else
      metadata[:parent_example_group]
    end

    if example_group
      [filename_for(example_group), description].join('/')
    else
      description
    end
  end

end
