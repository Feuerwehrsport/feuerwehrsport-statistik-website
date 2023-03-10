# frozen_string_literal: true

Calculation::Competition = Struct.new(:competition, :context) do
  attr_accessor :single_score_count
  attr_reader :disciplines, :single_categories, :group_categories

  Calculation::CompetitionDiscipline = Struct.new(:calculation, :discipline, :gender, :category, :context) do
    attr_reader :count, :scores, :all_scores

    def initialize(*args)
      super
      calculate_scores
    end

    def match?(discipline, gender, category)
      self.discipline == discipline && self.gender == gender && self.category == category
    end

    def chart
      @chart ||= Chart::CompetitionDisciplineCategoryOverview.new(discipline: self, context:)
    end
  end

  class Calculation::CompetitionSingleDiscipline < Calculation::CompetitionDiscipline
    def calculate_scores
      scores = calculation.competition.scores.discipline(discipline).gender(gender)
      scores = category == false ? scores.no_finals : scores.finals(category)
      @all_scores = scores
      @scores = @all_scores.best_of_competition.decorate
      @count = @scores.size
      calculation.single_score_count += count
    end
  end

  class Calculation::CompetitionDoubleEventDiscipline < Calculation::CompetitionDiscipline
    def calculate_scores
      @scores = calculation.competition.score_double_events.gender(gender).decorate
      @count = @scores.size
    end
  end

  class Calculation::CompetitionLowDoubleEventDiscipline < Calculation::CompetitionDoubleEventDiscipline
    def calculate_scores
      @scores = calculation.competition.score_low_double_events.gender(gender).decorate
      @count = @scores.size
    end
  end

  class Calculation::CompetitionGroupDiscipline < Calculation::CompetitionDiscipline
    def calculate_scores
      @all_scores = calculation.competition.group_scores.where(group_score_category: category).gender(gender)
      @scores = @all_scores.best_of_competition.decorate
      @count = @scores.size
    end
  end

  def initialize(*args)
    super
    @single_score_count = 0
    @disciplines = []
    @single_categories = {}
    @group_categories = {}
    generate_disciplines
  end

  def discipline(discipline, gender, category = false)
    disciplines.find { |d| d.match?(discipline, gender, category) }
  end

  def generate_disciplines
    %i[hb hw hl].each do |discipline|
      %i[female male].each do |gender|
        [false, -1, -2, -3, -4].each do |final|
          single = Calculation::CompetitionSingleDiscipline.new(self, discipline, gender, final, context)
          next unless single.count > 0

          @single_categories[discipline] ||= Set.new
          @single_categories[discipline].add(final)
          @disciplines.push(single)
        end
      end
    end

    %i[female male].each do |gender|
      double_event = Calculation::CompetitionDoubleEventDiscipline.new(self, :zk, gender, nil, context)
      @disciplines.push(double_event) if double_event.count > 0
      low_double_event = Calculation::CompetitionLowDoubleEventDiscipline.new(self, :zk, gender, nil, context)
      @disciplines.push(low_double_event) if low_double_event.count > 0
    end

    %i[gs fs la].each do |discipline|
      %i[female male].each do |gender|
        competition.group_score_categories.discipline(discipline).decorate.each do |category|
          group = Calculation::CompetitionGroupDiscipline.new(self, discipline, gender, category, context)
          next unless group.count > 0

          @group_categories[discipline] ||= Set.new
          @group_categories[discipline].add(category)
          @disciplines.push(group)
        end
      end
    end
  end
end
