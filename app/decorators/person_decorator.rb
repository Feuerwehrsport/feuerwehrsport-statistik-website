class PersonDecorator < ApplicationDecorator
  decorates_association :nation

  def to_s
    last_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
