module API
  class ImportsController < BaseController
    before_action :authorize_action
    def check_lines
      check = Import::Check.new(check_params)
      if check.valid?
        check.import_lines!
        success(import_lines: check.import_lines, missing_teams: check.missing_teams)
      else
        failed(message: check.errors.full_messages.to_sentence)
      end
    end

    def scores
      import = Import::Scores.new(import_params)
      if import.valid?
        begin
          import.save!
          success
        rescue ActiveRecord::RecordInvalid => e
          failed(message: e.message)
        end
      else
        failed(message: import.errors.full_messages.to_sentence)
      end
    end

    protected

    def authorize_action
      authorize!(:create, GroupScore)
      authorize!(:create, Score)
      authorize!(:create, Team)
      authorize!(:create, Person)
    end

    def check_params
      params.require(:import).permit(:discipline, :gender, :raw_lines, :separator, :raw_headline_columns)
    end

    def import_params
      valid_score_params = [
        :team_number,
        :team_id,
        :run,
        {times: []},
        :person_id,
        :last_name,
        :first_name,
      ]

      params.require(:import).permit(:discipline, :gender, :competition_id, :group_score_category_id, scores: valid_score_params)
    end
  end
end
