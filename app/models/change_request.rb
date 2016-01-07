class ChangeRequest < ActiveRecord::Base 
  belongs_to :user
  belongs_to :admin_user

  scope :open, -> { where(done_at: nil) }

  validates :content, presence: true

  def content
    super.deep_symbolize_keys
  end

  def files_data
    super.deep_symbolize_keys
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

  def done=(done_status)
    if done_status.to_i == 1 && done_at.nil?
      self.done_at = Time.now
    elsif done_status.to_i == 0
      self.done_at = nil
    end
  end
end
