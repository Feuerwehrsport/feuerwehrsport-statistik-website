# frozen_string_literal: true
class ImportRequestFile < ApplicationRecord
  belongs_to :import_request, class_name: 'ImportRequest'
  mount_uploader :file, ImportRequestUploader
  validate :transfer_competition_file_valid
  before_save :save_transfer_competition_file

  def transfer_competition_id=(competition_id)
    transfer_competition_file.competition = Competition.find(competition_id)
  end

  def transfer_keys_string=(keys_string)
    transfer_competition_file.keys_string = keys_string
  end

  def pdf?
    file.content_type == Mime[:pdf]
  end

  protected

  def transfer_competition_file
    @transfer_competition_file ||= CompetitionFile.new(file: File.open(file.path))
  end

  def transfer_competition_file_valid
    return if @transfer_competition_file.nil? || transfer_competition_file.valid?

    errors.add(:transfer_competition_file, :invalid)
  end

  def save_transfer_competition_file
    return if @transfer_competition_file.nil?

    transfer_competition_file.save!
    self.transfered = true
  end
end
