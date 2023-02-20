# frozen_string_literal: true
class ImportRequest < ApplicationRecord
  belongs_to :place
  belongs_to :event
  belongs_to :admin_user
  belongs_to :edit_user, class_name: 'AdminUser'
  has_many :import_request_files, class_name: 'ImportRequestFile', dependent: :destroy, inverse_of: :import_request
  accepts_nested_attributes_for :import_request_files, reject_if: proc { |attributes| attributes['file'].blank? }

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

  def import_data
    super.try(:with_indifferent_access)
  end

  def competition_info
    info = import_data&.except(:results) || {}
    info[:place] ||= place.name if place.present?
    info[:event] ||= event.name if event.present?
    info[:date] ||= date.to_s if date.present?
    info
  end

  def compressed_data=(data)
    json = JSON.parse(Zlib::Inflate.inflate(data), symbolize_names: true)
    self.date = json[:date]
    self.description = json[:name]
    import_data = {
      date: json[:date],
      name: json[:name],
      place: json[:place],
      results: [],
    }
    json[:files].try(:each) do |file|
      data = Base64.decode64(file[:base64_data])
      if file[:mimetype] == Mime[:json] && JSON.parse(data, symbolize_names: true)[:discipline].present?
        import_data[:results].push(JSON.parse(data, symbolize_names: true))
      else
        import_request_files.new(
          file: CarrierStringIO.new(data, file[:name], file[:mimetype]),
        )
      end
    end
    self.import_data = import_data
  end

  private

  def remove_old_entries
    self.class.old_entries.destroy_all
  end
end
