# frozen_string_literal: true

module NumberedTeamNames
  def numbered_team_name(score, options = {})
    return '' if score.team.blank?

    number_name = if score.team_number.zero?
                    ' E'
                  elsif score.team_number.between?(-4, -1)
                    ' F'
                  elsif score.team_number == -5
                    ' A'
                  else
                    options[:competition_id] ||= score.try(:competition_id) || score.try(:competition).try(:id)
                    options[:team_id] ||= score.try(:team_id)
                    options[:gender] ||= score.try(:gender) || score.try(:person).try(:gender)

                    c = team_number_count(options[:competition_id], options[:team_id], options[:gender])
                    c > 1 ? " #{score.team_number}" : ''
                  end

    run = score.try(:run).present? ? " #{score.run}" : ''
    score.team.shortcut + number_name + run
  end

  # loads the team numbers of many competitions with one query (e.g. all competitions of a person)
  def self.preload_team_numbers(competition_ids)
    counts = (Current.team_number_counts ||= {})
    competition_ids = competition_ids.uniq - counts.keys
    return if competition_ids.empty?

    competition_ids.each { |id| counts[id] = {} }
    CompetitionTeamNumber.where(competition_id: competition_ids).group(:competition_id, :team_id, :gender)
                         .distinct.count(:team_number).each do |(competition_id, team_id, gender), count|
      counts[competition_id][[team_id, gender]] = count
    end
  end

  private

  # number of different team numbers of a team in a competition; loaded once per competition and request
  def team_number_count(competition_id, team_id, gender)
    counts = (Current.team_number_counts ||= {})
    gender = { 0 => 'female', 1 => 'male' }.fetch(gender, gender).to_s
    if competition_id.is_a?(Array) # series: team numbers over several competitions
      counts[[competition_id.sort, team_id, gender]] ||=
        CompetitionTeamNumber.gender(gender).where(competition_id:, team_id:).distinct.count(:team_number)
    else
      counts[competition_id] ||= CompetitionTeamNumber.where(competition_id:).group(:team_id, :gender)
                                                      .distinct.count(:team_number)
      counts[competition_id].fetch([team_id, gender], 0)
    end
  end
end
