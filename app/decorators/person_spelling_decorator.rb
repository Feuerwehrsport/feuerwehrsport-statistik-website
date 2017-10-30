class PersonSpellingDecorator < AppDecorator
  decorates_association :person
  localizes_gender
  localizes_boolean :official

  def to_s
    full_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
