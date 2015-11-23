class PersonDecorator < ApplicationDecorator
  include Indexable
  decorates_association :nation
  index_columns :id, :first_name, :last_name, :translated_gender

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
