# frozen_string_literal: true

class ChangeRequest < ApplicationRecord
  belongs_to :api_user
  belongs_to :admin_user

  scope :open, -> { where(done_at: nil) }
  scope :old_entries, -> { where(arel_table[:done_at].lt(3.months.ago)) }
  after_create :remove_old_entries

  validates :content, presence: true

  def user=(user)
    case user
    when ApiUser
      self.api_user = user
    when AdminUser
      self.admin_user = user
    end
  end

  def user
    admin_user || api_user
  end

  def content
    (super || {}).deep_symbolize_keys
  end

  def files_data
    (super || {}).deep_symbolize_keys
  end

  # see http://stackoverflow.com/questions/6977968/sending-uploaded-file-to-resque-worker-to-be-processed
  def files=(files)
    files_array = []

    files.each do |file|
      next unless file.is_a?(ActionDispatch::Http::UploadedFile)

      file.tempfile.binmode
      files_array.push(
        binary: Base64.encode64(file.tempfile.read),
        filename: file.original_filename,
        content_type: file.content_type,
      )
    end
    self.files_data = { files: files_array }
  end

  def files
    objects = files_data[:files] || []
    objects.map do |object|
      ChangeRequestFile.new(object)
    end
  end

  def done=(done_status)
    if done_status.to_i == 1 && done_at.nil?
      self.done_at = Time.current
    elsif done_status.to_i.zero?
      self.done_at = nil
    end
  end

  class ChangeRequestFile < StringIO
    attr_reader :filename, :content_type, :binary
    alias original_filename filename

    def initialize(object)
      @filename = object[:filename]
      @content_type = object[:content_type]
      @binary = object[:binary]
      super(Base64.decode64(@binary))
    end

    def to_h
      {
        filename: filename,
        content_type: content_type,
        binary: binary,
      }
    end
  end

  private

  def remove_old_entries
    self.class.old_entries.destroy_all
  end
end
