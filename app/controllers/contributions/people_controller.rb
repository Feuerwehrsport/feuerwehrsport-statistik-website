# frozen_string_literal: true

class Contributions::PeopleController < Contributions::BaseController
  def new
    @person = Person.new
    authorize!(:create, @person)
  end

  def create
    @person = Person.new(params.expect(person: %i[first_name last_name gender nation_id]))
    authorize!(:create, @person)

    saved = Person.transaction do
      @person.save && log_change(@person, serializer: PersonSerializer)
    end
    if saved
      clean_cache
      render :created
    else
      render :new, status: :unprocessable_content
    end
  end
end
