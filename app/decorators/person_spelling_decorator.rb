class PersonSpellingDecorator < ApplicationDecorator
  include Indexable
  index_columns :id, :person, :first_name, :last_name, :gender, :official

  decorates_association :person

  def to_s
    full_name
  end  

  def full_name
    "#{first_name} #{last_name}"
  end
end
