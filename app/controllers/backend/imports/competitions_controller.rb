# frozen_string_literal: true

# creates the competition of an import inside the import page (turbo frame "import-competition"),
# with a new place and event if needed, and selects it for the import afterwards
class Backend::Imports::CompetitionsController < Backend::BackendController
  include ChangeLogging

  layout false
  before_action { authorize!(:create, Competition) }
  before_action :assign_return_to

  def new
    @competition = Competition.new(name: params[:name], date: params[:date])
    @new_place_name = params[:place].to_s.strip
    @competition.place = find_by_name(Place, @new_place_name)
    @new_place_name = '' if @competition.place
    @new_event_name = params[:event].to_s.strip
    @competition.event = find_by_name(Event, @new_event_name)
    @new_event_name = '' if @competition.event
  end

  def create
    @competition = Competition.new(params.expect(competition: %i[name date place_id event_id]))
    @new_place_name = params[:new_place_name].to_s.strip
    @new_event_name = params[:new_event_name].to_s.strip

    if save_competition
      session[Backend::ImportCompetitionSelection::SESSION_KEY] = @competition.id
      clean_cache
      render :created
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  # selected place/event wins, otherwise the new name is used (existing record with that name or a new one)
  def save_competition
    Competition.transaction do
      @competition.place = find_or_create(Place, @new_place_name) if @competition.place_id.blank?
      @competition.event = find_or_create(Event, @new_event_name) if @competition.event_id.blank?
      raise ActiveRecord::Rollback unless @competition.save

      log_change(@competition, serializer: CompetitionSerializer)
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    @competition.errors.add(:base, e.record.errors.full_messages.to_sentence)
    false
  ensure
    reset_unsaved_associations
  end

  def find_by_name(model, name)
    model.find_by('LOWER(name) = LOWER(?)', name) if name.present?
  end

  def find_or_create(model, name)
    return if name.blank?

    find_by_name(model, name) || begin
      authorize!(:create, model)
      model.create!(name:).tap { log_change(it, serializer: "#{model.name}Serializer".constantize) }
    end
  end

  # records of a rolled back transaction must not be shown as selected
  def reset_unsaved_associations
    @competition.place = nil if @competition.place && !Place.exists?(@competition.place.id)
    @competition.event = nil if @competition.event && !Event.exists?(@competition.event.id)
  end

  # only paths inside the backend; the selection is stored in the session, so the competition_id is removed
  def assign_return_to
    path = URI.parse(params[:return_to].to_s).path
    @return_to = path&.start_with?('/backend/') ? path : backend_imports_path
  rescue URI::InvalidURIError
    @return_to = backend_imports_path
  end
end
