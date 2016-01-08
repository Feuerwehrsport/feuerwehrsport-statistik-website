class PersonSpelling < ActiveRecord::Base
  include Genderable

  belongs_to :person

  validates :person, :first_name, :last_name, :gender, presence: true

  def self.create_from(person, incorrect_person)
    create!(
      person: person, 
      first_name: incorrect_person.first_name, 
      last_name: incorrect_person.last_name,
      gender: incorrect_person.gender,
    )
  end
end
