class AdminUserDecorator < AppDecorator
  def to_s
    name
  end

  def name_with_role
    "#{role}: #{name}"
  end

  def email_address_format
    address = Mail::Address.new(email_address)
    display_name = name.to_s.dup.presence
    address.display_name = display_name if display_name
    address.format
  end
end
