# frozen_string_literal: true

class ImportRequestFile < ApplicationRecord
  belongs_to :import_request, class_name: 'ImportRequest'
  mount_uploader :file, ImportRequestUploader
  validate :transfer_competition_file_valid
  before_save :save_transfer_competition_file
  schema_validations

  def transfer_competition_id=(competition_id)
    transfer_competition_file.competition = Competition.find(competition_id)
  end

  def transfer_keys_string=(keys_string)
    transfer_competition_file.keys_string = keys_string
  end

  def pdf?
    file.content_type == Mime[:pdf]
  end

  GUESS_DISCIPLINES = {
    zk: /zweikampf/i, hb: /hindernisbahn|hindernislauf/i, hl: /hakenleiter/i, gs: /gruppenstafette/i,
    fs: /staffel|feuerwehrstafette|4x100/i, la: /l.schangriff|LA/
  }.freeze

  # results contained in the file, guessed from the file name (keys of CompetitionFile)
  def guessed_keys
    name = file_identifier.to_s
    genders = { female: name.match?(/Frauen|weiblich|M.dchen/i), male: name.match?(/M.nner|m.nnlich|Jungen/i) }
    CompetitionFile::POSSIBLE_KEYS.select do |key|
      discipline, gender = key.to_s.split('_')
      genders[gender.to_sym] && name.match?(GUESS_DISCIPLINES[discipline.to_sym])
    end
  end

  protected

  def transfer_competition_file
    @transfer_competition_file ||= begin
      cf = CompetitionFile.new
      File.open(file.path) { |file| cf.file = file }
      cf
    end
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
