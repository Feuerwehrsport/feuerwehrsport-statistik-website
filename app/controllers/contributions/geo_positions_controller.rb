# frozen_string_literal: true

# position on the map of a team or place: the marker is moved on the page (stimulus geo-position),
# saving opens this dialog with the new coordinates
class Contributions::GeoPositionsController < Contributions::BaseController
  before_action :assign_record

  def edit
    @latitude, @longitude = coordinates
    @error = 'Die Position ist ungültig.' if @latitude.nil?
    @offer_check = offer_check?
    return unless @type == 'team'

    @state = State.from_place(params[:place_country], params[:place_state])
    @state = nil if @state == @record.state
  end

  def update
    @latitude, @longitude = coordinates
    if @latitude.nil?
      @error = 'Die Position ist ungültig.'
      return render :edit, status: :unprocessable_content
    end

    before_hash = @serializer.new(@record.decorate).as_json
    @checked = offer_check? && params[:checked] == '1'
    checked = @checked ? { checked_at: Time.current } : {}
    @record.class.transaction do
      @record.update!(latitude: @latitude, longitude: @longitude, **new_state, **checked)
      log_change(@record, serializer: @serializer, action: "update-#{@type}:geo-position", before_hash:)
    end
    clean_cache
    render :updated
  end

  private

  def assign_record
    if params[:team_id]
      @type = 'team'
      @record = Team.find(params[:team_id])
      @serializer = TeamSerializer
    else
      @type = 'place'
      @record = Place.find(params[:place_id])
      @serializer = PlaceSerializer
    end
    authorize!(:update, @record)
  end

  # from the backend list of new teams/places: offer to mark the record as checked together with the position
  def offer_check?
    list_class = @type == 'team' ? UncheckedTeam : UncheckedPlace
    params[:offer_check] == '1' && @record.checked_at.nil? && can?(:update, list_class)
  end

  # state of the chosen place (teams only), when confirmed in the dialog
  def new_state
    state = params[:state].presence
    @type == 'team' && state && State::ALL.key?(state) ? { state: } : {}
  end

  # [latitude, longitude] or nil when missing or out of range
  def coordinates
    latitude = Float(params[:latitude], exception: false)
    longitude = Float(params[:longitude], exception: false)
    return [nil, nil] unless latitude&.between?(-90, 90) && longitude&.between?(-180, 180)

    [latitude.round(6), longitude.round(6)]
  end
end
