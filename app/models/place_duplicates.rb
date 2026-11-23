# frozen_string_literal: true

# possible duplicates of a (new) place: similar names, ranked by the distance to the teams that started there
class PlaceDuplicates
  Candidate = Struct.new(:place, :score, :reasons, :distance)

  ABBREVIATIONS = { 'gr' => 'gross', 'kl' => 'klein', 'st' => 'sankt', 'ot' => '', 'b' => 'bei' }.freeze
  TRANSLITERATION = { 'ä' => 'ae', 'ö' => 'oe', 'ü' => 'ue', 'ß' => 'ss' }.freeze
  MIN_CONTAINED_LENGTH = 4
  MIN_SIMILAR_LENGTH = 4
  # [max km, score] for the distance of a candidate to the teams, beyond the last: -3
  DISTANCE_SCORES = [[30, 3], [80, 1], [250, 0]].freeze
  LIMIT = 15

  # comparable words: lower case, umlauts, abbreviations
  def self.name_words(name)
    words = name.to_s.downcase.gsub(/[äöüß]/, TRANSLITERATION).split(/[^a-z0-9]+/)
    words.map { |word| ABBREVIATIONS.fetch(word, word) }.compact_blank
  end

  # comparable key: the words without separators ("Groß-Laasch" = "Gr. Laasch")
  def self.name_key(name)
    name_words(name).join
  end

  def initialize(place)
    @place = place
  end

  def candidates
    @candidates ||= begin
      own_words = self.class.name_words(@place.name)
      candidates = Place.where.not(id: @place.id).filter_map do |place|
        reason, score = name_match(own_words, self.class.name_words(place.name))
        Candidate.new(place, score, [reason]) if reason
      end
      add_distance(candidates)
      candidates.sort_by { |c| [-c.score, c.place.name] }.first(LIMIT)
    end
  end

  def estimated_latlon
    return @estimated_latlon if defined?(@estimated_latlon)

    @estimated_latlon = @place.estimated_latlon
  end

  private

  def name_match(own_words, words)
    own = own_words.join
    key = words.join
    return if own.blank? || key.blank?

    if own == key
      ['gleicher Name', 8]
    elsif contained?(own_words, words)
      ['Name enthalten', 4]
    elsif similar?(own, key)
      ['ähnlicher Name', 3]
    end
  end

  def add_distance(candidates)
    return if estimated_latlon.nil?

    candidates.each do |candidate|
      next unless candidate.place.positioned?

      candidate.distance = GeoPosition.distance_km(estimated_latlon, candidate.place.latlon)
      candidate.score += DISTANCE_SCORES.find { |max, _score| candidate.distance <= max }&.last || -3
      candidate.reasons.push("ca. #{candidate.distance.round} km von den Mannschaften")
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

  # all words of the shorter name are words of the longer one ("Merzdorf" in "Cottbus Merzdorf")
  def contained?(first_words, second_words)
    shorter, longer = [first_words, second_words].sort_by(&:size)
    shorter.join.length >= MIN_CONTAINED_LENGTH && (shorter - longer).empty?
  end
end
