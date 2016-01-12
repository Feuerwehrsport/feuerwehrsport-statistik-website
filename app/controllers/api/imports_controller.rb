module API
  class ImportsController < BaseController
    def check_lines
      check = Import::Check.new(import_params)
      if check.valid?
        check.import_lines!
        success(import_lines: check.import_lines, missing_teams: check.missing_teams)
      else
        failed(message: check.errors.full_messages.to_sentence)
      end
    end

    def import_params
      params.require(:import).permit(:discipline, :gender, :raw_lines, :seperator, :raw_headline_columns)
    end
  end
end
