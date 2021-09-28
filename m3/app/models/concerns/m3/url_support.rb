# frozen_string_literal: true

module M3::URLSupport
  extend ActiveSupport::Concern
  included { include Rails.application.routes.url_helpers }

  protected

  def default_url_options(website = M3::Website.first, params = {})
    params.merge(
      host: website.domain,
      port: website.port,
      protocol: website.protocol,
    )
  end
end
