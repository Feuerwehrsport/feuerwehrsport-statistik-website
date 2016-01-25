class PersonSpellingDecorator < ApplicationDecorator
  def to_s
    full_name
  end  

  def full_name
    "#{first_name} #{last_name}"
  end
end
