# frozen_string_literal: true

class ApiUserSerializer < UserSerializer
  attributes :named_email_address

  def name
    object.name.presence || object.email_address
  end
end
