# frozen_string_literal: true

class People::CleanerDecorator < AppDecorator
  def people
    h.render('people_list', people: object.people.decorate)
  end
end
