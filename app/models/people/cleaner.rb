# frozen_string_literal: true

class People::Cleaner
  include FormObject

  def people
    Person.unused
  end
end
