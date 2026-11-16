# frozen_string_literal: true

# position on the map of a team or place: the marker is moved on the page (stimulus geo-position),
# saving opens this dialog with the new coordinates
class Contributions::GeoPositionsController < Contributions::BaseController
  before_action :assign_record

  def edit
    @latitude, @longitude = coordinates
    @error = 'Die Position ist ungültig.' if @latitude.nil?
  end

  def update
    @latitude, @longitude = coordinates
    if @latitude.nil?
      @error = 'Die Position ist ungültig.'
      return render :edit, status: :unprocessable_content
    end

    before_hash = @serializer.new(@record.decorate).as_json
    @record.class.transaction do
      @record.update!(latitude: @latitude, longitude: @longitude)
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

  # [latitude, longitude] or nil when missing or out of range
  def coordinates
    latitude = Float(params[:latitude], exception: false)
    longitude = Float(params[:longitude], exception: false)
    return [nil, nil] unless latitude&.between?(-90, 90) && longitude&.between?(-180, 180)

    [latitude.round(6), longitude.round(6)]
  end
end
