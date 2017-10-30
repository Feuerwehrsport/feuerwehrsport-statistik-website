class GroupScoreCategoryDecorator < AppDecorator
  decorates_association :competition
  decorates_association :group_score_type

  def to_s
    name == 'default' ? 'Standardwertung' : name
  end

  def with_competition
    "#{self} - #{competition}"
  end

  delegate :discipline, to: :group_score_type

  def shortcut(options = {})
    name == 'default' ? '' : "#{options[:prefix]}#{name}"
  end
end
