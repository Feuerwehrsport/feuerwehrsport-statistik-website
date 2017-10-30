class ImportRequest < ActiveRecord::Base
  belongs_to :place
  belongs_to :event
  belongs_to :admin_user
  belongs_to :edit_user, class_name: 'AdminUser'

  mount_uploader :file, ImportRequestUploader

  default_scope -> { order('finished_at DESC, created_at ASC') }

  def edit_user_id=(id)
    super
    if edit_user_id_changed?
      self.edited_at = Time.now if id.present?
      self.edited_at = nil if id.blank?
    end
  end

  def finished
    finished_at.present?
  end

  def finished=(value)
    self.finished_at = if value == '0'
                         nil
                       else
                         Time.now
                       end
  end
end
