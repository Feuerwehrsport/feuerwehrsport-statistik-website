# frozen_string_literal: true

class ImportRequest < ApplicationRecord
  belongs_to :place
  belongs_to :event
  belongs_to :admin_user
  belongs_to :edit_user, class_name: 'AdminUser'
  # step 1 of the import: competition the results are imported into
  belongs_to :competition
  has_many :import_request_files, class_name: 'ImportRequestFile', dependent: :destroy, inverse_of: :import_request
  accepts_nested_attributes_for :import_request_files, reject_if: proc { |attributes| attributes['file'].blank? }

  default_scope -> { order(finished_at: :desc, created_at: :asc) }
  scope :open, -> { where(finished_at: nil) }
  scope :old_entries, -> { where(arel_table[:finished_at].lt(3.months.ago)) }

  after_create :remove_old_entries
  schema_validations

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

  def import_data_results
    @import_data_results ||= import_data[:results].select { |result| result[:rows].many? }
  end

  def import_data_series_rounds
    @import_data_series_rounds ||= import_data_results.map do |result|
      keys = (result[:series_person_round_keys] || []) + (result[:series_team_round_keys] || [])
      round_ids = keys.filter_map { |key| key[/\A(\d+)-/, 1] }
      Series::Round.where(id: round_ids.uniq)
    end.flatten.uniq
  end

  # results are identified by their index in import_data_results and the gender (results of Feusport without
  # gender can be imported for both)
  def result_imported?(index, gender)
    imported_result_keys.include?("#{index}-#{gender}")
  end

  # created_ids: records of the import (Import::Scores#created_ids, category_id of a new category), several
  # imports of the same result are collected
  def mark_result_imported!(index, gender, created_ids = {})
    key = "#{index}-#{gender}"
    entry = imported_results[key] || {}
    created_ids.each { |name, ids| entry[name.to_s] = (Array(entry[name.to_s]) + Array(ids)).uniq }
    entry['imported_at'] = Time.current.iso8601
    update!(imported_result_keys: (imported_result_keys + [key]).uniq,
            imported_results: imported_results.merge(key => entry))
  end

  def imported_result(index, gender)
    imported_results["#{index}-#{gender}"]
  end

  # deletes the records of the import of a result (people and a category only if they are unused now)
  def undo_result_import!(index, gender)
    key = "#{index}-#{gender}"
    entry = imported_results[key] || {}
    transaction do
      Score.where(id: entry['score_ids']).destroy_all
      group_scores = GroupScore.where(id: entry['group_score_ids'])
      PersonParticipation.where(group_score_id: group_scores.select(:id)).delete_all
      group_scores.destroy_all
      Person.where(id: entry['person_ids']).find_each do |person|
        person.destroy
      rescue ActiveRecord::DeleteRestrictionError
        nil # used by other scores
      end
      GroupScoreCategory.where(id: entry['category_ids']).find_each do |category|
        category.destroy if category.group_scores.none?
      end
      update!(imported_result_keys: imported_result_keys - [key], imported_results: imported_results.except(key))
    end
    entry
  end

  def series_round_imported?(round)
    imported_result_keys.include?("series-#{round.id}")
  end

  def mark_series_round_imported!(round)
    update!(imported_result_keys: (imported_result_keys + ["series-#{round.id}"]).uniq)
  end

  def person_points_corrections(round_key, person_id)
    (import_data[:person_points_corrections] || []).find do |c|
      c[:round_key] == round_key && c[:person_id] == person_id
    end
  end

  def team_points_corrections(round_key, team_id, team_number, discipline)
    (import_data[:team_points_corrections] || []).find do |c|
      c[:round_key] == round_key &&
        c[:team_id] == team_id &&
        c[:team_number] == team_number &&
        c[:discipline] == discipline
    end
  end

  def competition_info
    info = import_data&.except(:results) || {}
    info[:place] ||= place.name if place.present?
    info[:event] ||= event.name if event.present?
    info[:date] ||= date.to_s if date.present?
    info
  end

  def compressed_data=(data)
    json = JSON.parse(Zlib::Inflate.inflate(Base64.decode64(data)), symbolize_names: true)
    self.date = json[:date]
    self.description = <<~STRING
      Name: #{json[:name]}
      Datum: #{json[:date]}
      Ort: #{json[:place]}
      Nutzer: #{json[:user]}
      E-Mail-Adresse: #{json[:user_email_address]}
      URL: #{json[:url]}

      #{json[:hint]}
    STRING
    self.url = json[:url]
    import_data = {
      date: json[:date],
      name: json[:name],
      place: json[:place],
      results: [],
      person_points_corrections: json[:person_points_corrections],
      team_points_corrections: json[:team_points_corrections],
    }
    json[:files].try(:each) do |file|
      data = Base64.decode64(file[:base64_data])
      if file[:mimetype] == Mime[:json] && JSON.parse(data, symbolize_names: true)[:discipline].present?
        import_data[:results].push(JSON.parse(data, symbolize_names: true))
      else
        import_request_files.new(
          file: CarrierStringIo.new(data, file[:name], file[:mimetype]),
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
