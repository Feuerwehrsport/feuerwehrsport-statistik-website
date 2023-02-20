# frozen_string_literal: true

class API::ImportRequestFilesController < API::BaseController
  api_actions :update,
              default_form: %i[transfer_competition_id transfer_keys_string]
end
