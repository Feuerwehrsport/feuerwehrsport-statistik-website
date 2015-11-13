class PersonDecorator < ApplicationDecorator
  decorates_association :nation

  def to_s
    last_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def short_name
    "#{first_name[0]}. #{last_name}"
  end
end
