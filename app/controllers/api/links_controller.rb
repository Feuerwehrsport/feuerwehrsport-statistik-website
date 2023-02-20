# frozen_string_literal: true

class Api::LinksController < Api::BaseController
  api_actions :create, :show, :destroy,
              change_log: true,
              default_form: %i[label url linkable_type linkable_id]
end
