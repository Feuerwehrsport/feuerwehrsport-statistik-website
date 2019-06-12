class ImportRequest < ActiveRecord::Base
  belongs_to :place
  belongs_to :event
  belongs_to :admin_user
  belongs_to :edit_user, class_name: 'AdminUser'

  mount_uploader :file, ImportRequestUploader

  default_scope -> { order('finished_at DESC, created_at ASC') }
  scope :open, -> { where(finished_at: nil) }
  scope :old_entries, -> { where(arel_table[:finished_at].lt(3.months.ago)) }

  after_create :remove_old_entries

  def edit_user_id=(id)
    super
    return unless edit_user_id_changed?

    self.edited_at = Time.current if id.present?
    self.edited_at = nil if id.blank?
  end

  def finished
    finished_at.present?
  end

  def finished=(value)
    self.finished_at = value == '0' ? nil : Time.current
  end

  def compressed_data=(data)
    json_string = Zlib::Inflate.inflate(data)
    file = Tempfile.new(['compressed_data', '.json'])
    file.write(json_string)
    self.file = file
  end

  private

  def remove_old_entries
    self.class.old_entries.destroy_all
  end
end
