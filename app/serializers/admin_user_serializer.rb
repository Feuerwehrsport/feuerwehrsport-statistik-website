require 'mail'

class AdminUserSerializer < UserSerializer
  attributes :named_email_address

  def named_email_address
    address = Mail::Address.new(object.email_address)
    display_name = object.name.to_s.dup.presence
    address.display_name = display_name if display_name
    address.format
  end
end
