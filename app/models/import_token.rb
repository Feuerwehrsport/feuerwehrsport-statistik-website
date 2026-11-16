# frozen_string_literal: true

# Static token for trusted systems (Feusport) that transfer results as import requests.
# Tokens are configured via ENV['FEUSPORT_IMPORT_TOKENS'] (comma separated, allows rotation).
class ImportToken
  def self.authenticate(token)
    return if token.blank?

    valid = Rails.configuration.x.feusport_import_tokens.any? do |configured|
      ActiveSupport::SecurityUtils.secure_compare(configured, token)
    end
    new if valid
  end

  def role
    :import_token
  end
end
