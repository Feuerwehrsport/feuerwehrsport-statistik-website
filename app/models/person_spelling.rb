class PersonSpelling < ActiveRecord::Base
  include Genderable

  belongs_to :person

  scope :search_exactly, -> (last_name, first_name) do
    where("last_name ILIKE ? AND first_name ILIKE ?", last_name, first_name)
  end

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