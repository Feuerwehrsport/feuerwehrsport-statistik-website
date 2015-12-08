class CompetitionFileDecorator < ApplicationDecorator
  decorates_association :competition
  include Indexable
  index_columns :file_identifier, :competition

  def to_s
    file_identifier
  end

  def human_keys
    object.keys.map do |key|
      discipline, gender = key.split("-")
      gender = :female if gender.nil? && discipline == "gs"
      gender = :male if gender.nil? && discipline == "hl"
      "#{discipline_name_short(discipline)} #{g_symbol(gender)}"
    end
  end
end
