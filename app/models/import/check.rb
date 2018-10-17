module Import
  class Check
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks
    attr_accessor :discipline, :gender, :raw_lines, :separator, :raw_headline_columns, :lines, :headline_columns,
                  :import_lines, :missing_teams

    validates :discipline, :gender, :lines, :headline_columns, presence: true
    validates :separator, length: { minimum: 1 }
    validates :discipline, inclusion: { in: Discipline::WITHOUT_DOUBLE_EVENT }
    validates :gender, inclusion: { in: %w[female male] }
    validate :required_columns_present_validation
    validate :column_count_validation

    before_validation do
      if separator.is_a?(String)
        self.lines = raw_lines.split("\n").map { |line| line.strip.split(separator) } if raw_lines.is_a?(String)
        self.headline_columns = raw_headline_columns.split(separator) if raw_headline_columns.is_a?(String)
      end
    end

    def initialize(*args)
      super
      self.lines = []
      self.headline_columns = []
      self.import_lines = []
      self.missing_teams = []
    end

    def discipline=(discipline)
      @discipline = discipline.try(:to_sym)
    end

    def add_missing_team(team_name)
      missing_teams.push(team_name)
      missing_teams.uniq!
    end

    def import_lines!
      return unless valid?

      self.missing_teams = []
      self.import_lines = lines.map { |line| Line.new(self, line).out.to_h }
    end

    private

    def required_columns_present_validation
      columns = ['time']
      if Discipline.group?(discipline)
        columns.push('team')
      else
        columns.push('first_name', 'last_name')
      end
      unless columns.map { |column| headline_columns.try(:include?, column) }.all?
        errors.add(:headline_columns, " has not all required columns (#{columns.join(', ')} for #{discipline})")
      end
    end

    def column_count_validation
      errors.add(:raw_lines, ' has not enough columns') if lines.any? { |line| line.count != headline_columns.count }
    end
  end
end
