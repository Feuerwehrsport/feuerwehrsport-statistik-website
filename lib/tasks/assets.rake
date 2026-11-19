# frozen_string_literal: true

# Propshaft only digests. After assets:precompile, write a maximally compressed .gz next to each text asset, nginx
# serves it with `gzip_static on` (instead of compressing on the fly with a low level). Orphaned .gz files (source
# removed by assets:clean) are deleted.
namespace :assets do
  desc 'Write .gz files for the text assets in public/assets'
  task gzip: :environment do
    require 'zlib'
    output = Rails.application.config.assets.output_path

    output.glob('**/*.gz').each { |gz| gz.delete unless gz.sub_ext('').exist? }
    output.glob('**/*.{css,js,svg,json,txt,map}').each do |file|
      gz = Pathname.new("#{file}.gz")
      next if gz.exist? && gz.mtime >= file.mtime

      Zlib::GzipWriter.open(gz, Zlib::BEST_COMPRESSION) do |writer|
        writer.mtime = file.mtime
        writer.write(file.binread)
      end
    end
  end
end

Rake::Task['assets:precompile'].enhance { Rake::Task['assets:gzip'].invoke }
