# frozen_string_literal: true
module NumberedTeamNames
  def numbered_team_name(score, options = {})
    return '' if score.team.blank?

    number_name = begin
      if score.team_number.zero?
        ' E'
      elsif score.team_number <= -1 && score.team_number >= -4
        ' F'
      elsif score.team_number == -5
        ' A'
      else
        options = {
          competition_id: score.try(:competition).try(:id),
          team_id: score.try(:team_id),
          gender: score.try(:gender) || score.try(:person).try(:gender),
        }.merge(options)
        c = CompetitionTeamNumber
            .gender(options[:gender])
            .where(competition_id: options[:competition_id], team_id: options[:team_id])
            .distinct.count(:team_number)
        c > 1 ? " #{score.team_number}" : ''
      end
    end
    run = score.try(:run).present? ? " #{score.run}" : ''
    score.team.shortcut + number_name + run
  end
end
