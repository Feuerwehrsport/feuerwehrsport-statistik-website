# frozen_string_literal: true

# backend forms for single entries (person or team participation) of a series round, with change log;
# all actions return to the round page
module Backend::Series::ParticipationActions
  extend ActiveSupport::Concern

  included do
    include ChangeLogging

    before_action :assign_participation, only: %i[edit update destroy move]
    before_action { @page_title = 'Serieneintrag' } # the layout would otherwise use the generic resource
  end

  def new
    @participation = model_class.new(cup_id: params[:cup_id], **new_attributes)
    authorize!(:create, @participation)
    render 'backend/series/participations/form'
  end

  def create
    @participation = model_class.new(participation_params(:cup_id))
    authorize!(:create, @participation)
    save_and_return { @participation.save && log_change(@participation, serializer:) }
  end

  def edit
    render 'backend/series/participations/form'
  end

  def update
    before_hash = serialize_for_log(@participation, serializer)
    @participation.assign_attributes(participation_params)
    save_and_return { @participation.save && log_change(@participation, serializer:, before_hash:) }
  end

  # one rank up (and one point more) or down (one point less)
  def move
    before_hash = serialize_for_log(@participation, serializer)
    if params[:direction] == 'up'
      @participation.update!(rank: [@participation.rank - 1, 1].max, points: @participation.points + 1)
    else
      @participation.update!(rank: @participation.rank + 1, points: [@participation.points - 1, 0].max)
    end
    log_change(@participation, serializer:, action: "update-#{model_class.name.parameterize}", before_hash:)
    clean_cache
    redirect_to round_path, notice: "Jetzt Platz #{@participation.rank} mit #{@participation.points} Punkten."
  end

  def destroy
    before_hash = serialize_for_log(@participation, serializer)
    @participation.destroy!
    log_change(@participation, serializer:, before_hash:, after: false)
    clean_cache
    redirect_to round_path, notice: 'Der Eintrag wurde gelöscht.'
  end

  private

  def assign_participation
    @participation = model_class.find(params[:id])
    authorize!(:manage, @participation)
  end

  def save_and_return
    saved = model_class.transaction { yield || raise(ActiveRecord::Rollback) }
    if saved
      clean_cache
      redirect_to round_path, notice: 'Der Eintrag wurde gespeichert.'
    else
      render 'backend/series/participations/form', status: :unprocessable_content
    end
  end

  def participation_params(*extra)
    params.expect(model_class.model_name.param_key => [*permitted_attributes, *extra])
  end

  def round_path
    backend_series_round_path(@participation.cup.round)
  end
end
