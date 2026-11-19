# frozen_string_literal: true

# Propshaft only digests. After assets:precompile, write maximally compressed .gz files (and .br files, if the
# `brotli` command of the Debian package is installed) next to each text asset. nginx serves them with
# `gzip_static on` and `brotli_static on` instead of compressing on the fly with a low level. Orphaned files (source
# removed by assets:clean) are deleted.
namespace :assets do
  desc 'Write .gz (and .br) files for the text assets in public/assets'
  task gzip: :environment do
    require 'zlib'
    output = Rails.application.config.assets.output_path

    output.glob('**/*.{gz,br}').each { |compressed| compressed.delete unless compressed.sub_ext('').exist? }
    sources = output.glob('**/*.{css,js,svg,json,txt,map}')
    outdated = ->(file, ext) { !File.exist?("#{file}#{ext}") || File.mtime("#{file}#{ext}") < file.mtime }

    sources.select { |file| outdated.call(file, '.gz') }.each do |file|
      Zlib::GzipWriter.open("#{file}.gz", Zlib::BEST_COMPRESSION) do |writer|
        writer.mtime = file.mtime
        writer.write(file.binread)
      end
    end

    brotli = ENV['PATH'].to_s.split(File::PATH_SEPARATOR).map { |dir| File.join(dir, 'brotli') }
                        .find { |path| File.executable?(path) }
    if brotli
      # keeps the source and copies its mtime to the .br file
      outdated_br = sources.select { |file| outdated.call(file, '.br') }.map(&:to_s)
      outdated_br.each_slice(100) { |files| system(brotli, '--best', '--force', *files, exception: true) }
    else
      puts 'assets:gzip: brotli not installed (Debian package "brotli"), skipping .br files'
    end
  end
end

Rake::Task['assets:precompile'].enhance { Rake::Task['assets:gzip'].invoke }
