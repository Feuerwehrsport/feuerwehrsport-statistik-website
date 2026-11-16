# frozen_string_literal: true

# "Fehler mit dieser Person melden": choose the problem step by step, then send a change request
class Contributions::PersonChangeRequestsController < Contributions::BaseController
  # kinds with a form, the key of the change request is "person-<kind>"
  KINDS = %w[correction merge change-nation other].freeze
  # intermediate step: wrong spelling -> merge or correction
  STEPS = %w[wrong].freeze

  before_action :assign_person

  def new
    authorize!(:create, ChangeRequest)
    @kind = params[:kind].presence_in(KINDS + STEPS)
    @people = search_people if @kind == 'merge'
  end

  def create
    authorize!(:create, ChangeRequest)
    @kind = params[:kind].presence_in(KINDS)
    @error, data = change_request_data
    return render_error if @error

    create_change_request("person-#{@kind}", data)
    render :created
  end

  private

  def assign_person
    @person = Person.find(params[:person_id]).decorate
  end

  # ids are strings like the former api requests (FormData)
  def change_request_data
    person_id = @person.id.to_s
    case @kind
    when 'correction'
      first_name, last_name = params.values_at(:first_name, :last_name).map { |v| v.to_s.strip }
      return 'Bitte Vorname und Nachname angeben.' if first_name.blank? || last_name.blank?

      [nil, { person_id:, person: { first_name:, last_name: } }]
    when 'merge'
      correct_person = Person.where.not(id: @person.id).find_by(id: params[:correct_person_id])
      return 'Bitte die richtige Person auswählen.' if correct_person.nil?

      [nil, { person_id:, correct_person_id: correct_person.id.to_s }]
    when 'change-nation'
      nation = Nation.find_by(id: params[:nation_id])
      return 'Bitte eine Nation auswählen.' if nation.nil?

      [nil, { person_id:, nation_id: nation.id.to_s }]
    when 'other'
      description = params[:description].to_s.strip
      return 'Bitte beschreiben Sie das Problem.' if description.blank?

      [nil, { person_id:, description: }]
    else
      'Bitte wählen Sie das Problem aus.'
    end
  end

  def render_error
    @people = search_people if @kind == 'merge'
    render :new, status: :unprocessable_content
  end

  def search_people
    return Person.none if params[:q].to_s.strip.length < 2

    Person.where_name_like(params[:q].to_s.strip).where.not(id: @person.id)
          .reorder(:last_name, :first_name).limit(30).decorate
  end
end
