# frozen_string_literal: true

# possible duplicates of a (new) team, ranked by evidence: shared people and similar names (also known spellings),
# and the distance to the places of the competitions of the team (teams mostly start in their region)
class TeamDuplicates
  Candidate = Struct.new(:team, :score, :reasons)

  PREFIX = /\A(freiwillige feuerwehr|feuerwehr|ffw|ff|fw|team)\s+/
  # team number, run letter or gender, e.g. "Warin II", "Warin A", "Bürgel M"
  SUFFIX = /\s+(i|ii|iii|iv|[1-4]|[a-e]|m|w|damen|herren|frauen|männer|mix)\z/
  ABBREVIATIONS = { 'gr' => 'gross', 'kl' => 'klein', 'st' => 'sankt', 'ot' => '' }.freeze
  TRANSLITERATION = { 'ä' => 'ae', 'ö' => 'oe', 'ü' => 'ue', 'ß' => 'ss' }.freeze
  MIN_CONTAINED_LENGTH = 4
  MIN_SIMILAR_LENGTH = 4
  LIMIT = 15
  # [max km, score] for the distance of a candidate to the nearest competition place, beyond the last: -3
  DISTANCE_SCORES = [[30, 3], [80, 1], [250, 0]].freeze

  # comparable key of a team name: lower case, without prefix/suffix, umlauts, abbreviations and separators
  def self.name_key(name)
    key = name.to_s.downcase.strip
    2.times do
      key = key.sub(PREFIX, '')
      key = key.sub(SUFFIX, '')
    end
    key = key.gsub(/[äöüß]/, TRANSLITERATION)
    key.split(/[^a-z0-9]+/).map { |word| ABBREVIATIONS.fetch(word, word) }.join
  end

  def initialize(team)
    @team = team
  end

  def candidates
    @candidates ||= begin
      candidates = Hash.new { |hash, id| hash[id] = Candidate.new(nil, 0, []) }
      add_shared_people(candidates)
      add_similar_names(candidates)
      teams = Team.where(id: candidates.keys).index_by(&:id)
      candidates.each { |id, candidate| candidate.team = teams[id] }
      add_same_state(candidates.values)
      add_distance(candidates.values)
      candidates.values.select(&:team).sort_by { |c| [-c.score, c.team.name] }.first(LIMIT)
    end
  end

  # places of the competitions of the team with a position (anchor for distances)
  def competition_places
    @competition_places ||= begin
      competition_ids = TeamCompetition.where(team_id: @team.id).select(:competition_id)
      Place.positioned.where(id: Competition.where(id: competition_ids).select(:place_id)).reorder(:name).to_a
    end
  end

  # distance in km of a position to the nearest competition place and that place
  def nearest_competition_place(latlon)
    competition_places.map { |place| [GeoPosition.distance_km(latlon, place.latlon), place] }.min_by(&:first)
  end

  private

  def add_shared_people(candidates)
    people = TeamMember.where(team_id: @team.id).select(:person_id)
    TeamMember.where(person_id: people).where.not(team_id: @team.id).group(:team_id).count.each do |id, count|
      candidates[id].score += 10 + count
      candidates[id].reasons.push(count == 1 ? '1 gemeinsame Person' : "#{count} gemeinsame Personen")
    end
  end

  def add_similar_names(candidates)
    own_keys = [@team.name, @team.shortcut].map { |name| self.class.name_key(name) }.uniq.compact_blank
    return if own_keys.empty?

    known_names.each do |id, name, spelling|
      reason, score = name_match(own_keys, self.class.name_key(name))
      next if reason.nil? || candidates[id].reasons.any? { |known| known.start_with?(reason) }

      candidates[id].score += score
      candidates[id].reasons.push(spelling ? "#{reason} (Schreibweise „#{name}“)" : reason)
    end
    candidates.delete_if { |_id, candidate| candidate.reasons.empty? }
  end

  # [team_id, name, spelling?] of all other teams and their known spellings
  def known_names
    teams = Team.where.not(id: @team.id).pluck(:id, :name, :shortcut)
    spellings = TeamSpelling.where.not(team_id: @team.id).pluck(:team_id, :name, :shortcut)
    teams.flat_map { |id, name, shortcut| [[id, name, false], [id, shortcut, false]] } +
      spellings.flat_map { |id, name, shortcut| [[id, name, true], [id, shortcut, true]] }
  end

  def name_match(own_keys, key)
    return if key.blank?

    if own_keys.include?(key)
      ['gleicher Name', 8]
    elsif own_keys.any? { |own| contained?(own, key) }
      ['Name enthalten', 4]
    elsif own_keys.any? { |own| similar?(own, key) }
      ['ähnlicher Name', 3]
    end
  end

  # typo distance: 1 for short names, 2 for longer ones; very short names are too ambiguous
  def similar?(first, second)
    length = [first.length, second.length].min
    return false if length < MIN_SIMILAR_LENGTH

    max_distance = length < 8 ? 1 : 2
    (first.length - second.length).abs <= max_distance &&
      DidYouMean::Levenshtein.distance(first, second) <= max_distance
  end

  def contained?(first, second)
    shorter, longer = [first, second].sort_by(&:length)
    shorter.length >= MIN_CONTAINED_LENGTH && longer.include?(shorter)
  end

  def add_distance(candidates)
    return if competition_places.empty?

    candidates.each do |candidate|
      next unless candidate.team&.positioned?

      distance, place = nearest_competition_place(candidate.team.latlon)
      candidate.score += DISTANCE_SCORES.find { |max, _score| distance <= max }&.last || -3
      candidate.reasons.push("ca. #{distance.round} km von #{place.name}")
    end
  end

  def add_same_state(candidates)
    return if @team.state.blank?

    candidates.each do |candidate|
      next unless candidate.team&.state == @team.state

      candidate.score += 1
      candidate.reasons.push('gleiches Bundesland')
    end
  end
end
