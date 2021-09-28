# frozen_string_literal: true

require 'image_optim'

class M3::ApplicationUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  IMAGE_OPTIM_DEFAULT_OPTIONS = {
    skip_missing_workers: true,
    advpng: false,
    gifsicle: false,
    jhead: false,
    jpegrecompress: false,
    jpegtran: false,
    pngcrush: false,
    pngout: false,
    pngquant: false,
    svgo: false,
    jpegoptim: { max_quality: 75 },
    optipng: { level: 4 },
  }.freeze

  process :migration_warning

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def self.process_optimize_images(options = {})
    process optimize: [{
      jpegoptim: { strip: [:com], max_quality: 100 },
      jpegtran: true,
      optipng: { level: 2 },
      gifsicle: true,
    }.merge(options)]
  end

  def convert_and_fill(format, color, page = nil)
    manipulate! do |img|
      img.combine_options do |cmd|
        cmd.strip
        cmd.background color
        cmd.alpha 'remove'
      end
      img.format format, page
      @format = format
      img
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  # end

  def migration_warning
    return if caller.find { |line| line =~ %r{.+gems/activerecord.+migration\.rb.+migrate.+} }.blank?

    Rails.logger.fatal "Used an uploader in migration: #{inspect}"
    puts ''
    puts '============================================================'
    puts '============================================================'
    puts '============================================================'
    puts ''
    puts '       You use an uploader in a migration. This will'
    puts '                failed while deployment.'
    puts ''
    puts '============================================================'
    puts '============================================================'
    puts '============================================================'
    puts ''
  end

  def data_string(version = :itself)
    return nil if blank?
    return nil if send(version).blank?

    "data:#{send(version).content_type};base64,#{Base64.encode64(send(version).read).delete("\n")}"
  end

  def optimize(options = {})
    image_optim = ::ImageOptim.new(optimizer_options(options))
    image_optim.optimize_image!(current_path)
  end

  private

  def optimizer_options(options)
    IMAGE_OPTIM_DEFAULT_OPTIONS.deep_merge(options)
  end
end
