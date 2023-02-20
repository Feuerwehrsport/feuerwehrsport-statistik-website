# frozen_string_literal: true

module URLSupport
  extend ActiveSupport::Concern
  included { include Rails.application.routes.url_helpers }

  protected

  def default_url_options(params = {})
    params.reverse_merge(Rails.application.config.default_url_options)
  end
end
