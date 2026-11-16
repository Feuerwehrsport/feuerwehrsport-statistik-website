# frozen_string_literal: true

# open change requests of visitors: show the details and apply or close them
class Backend::ChangeRequestsController < Backend::BackendController
  include ChangeLogging

  before_action { authorize!(:manage, ChangeRequest) }
  before_action :assign_change_request, except: :index

  def index
    @change_requests = ChangeRequest.open.order(:created_at).includes(:api_user, :admin_user).decorate
  end

  def done
    @change_request.update!(done: 1)
    redirect_to backend_change_requests_path, notice: 'Als erledigt markiert.'
  end

  def apply
    ChangeRequest.transaction do
      apply_change
      @change_request.update!(done: 1)
    end
    clean_cache
    redirect_to backend_change_requests_path, notice: 'Der Fehler wurde behoben.'
  rescue ActiveRecord::ActiveRecordError, ArgumentError => e
    redirect_to backend_change_requests_path(anchor: "change-request-#{@change_request.id}"),
                alert: "Konnte nicht behoben werden: #{e.message}"
  end

  # uploaded files (e.g. logos): images inline, everything else as download
  def file
    file = @change_request.files[params[:index].to_i] || raise(ActiveRecord::RecordNotFound)
    image = file.content_type.to_s.start_with?('image/') && file.content_type != 'image/svg+xml'
    send_data(file.read, filename: file.filename, type: image ? file.content_type : 'application/octet-stream',
                         disposition: image ? 'inline' : 'attachment')
  end

  private

  def assign_change_request
    @change_request = ChangeRequest.find(params[:id])
  end

  def data
    @change_request.content[:data]
  end

  def apply_change
    case @change_request.content[:key]
    when 'competition-change-name'
      update_record(Competition.find(data[:competition_id]), CompetitionSerializer, 'update-competition:name',
                    name: params[:name].presence || data[:name])
    when 'person-correction'
      update_record(Person.find(data[:person_id]), PersonSerializer, 'update-person:name',
                    data[:person].slice(:first_name, :last_name))
    when 'person-change-nation'
      update_record(Person.find(data[:person_id]), PersonSerializer, 'update-person:nation',
                    nation_id: Nation.find(data[:nation_id]).id)
    when 'person-merge'
      merge(Person.find(data[:person_id]), Person.find(data[:correct_person_id]), PersonSerializer)
    when 'team-correction'
      update_record(Team.find(data[:team_id]), TeamSerializer, 'update-team:name',
                    data[:team].slice(:name, :shortcut, :status))
    when 'team-merge'
      merge(Team.find(data[:team_id]), Team.find(data[:correct_team_id]), TeamSerializer)
    when 'team-logo'
      raise ActiveRecord::RecordNotFound unless @change_request.files[params[:file_index].to_i]

      update_record(Team.find(data[:team_id]), TeamSerializer, 'update-team:image',
                    image_change_request: "#{@change_request.id}-#{params[:file_index].to_i}")
    when 'report-link'
      link = Link.find(data[:link_id])
      before_hash = serialize_for_log(link, LinkSerializer)
      link.destroy!
      log_change(link, serializer: LinkSerializer, action: 'destroy-link', before_hash:, after: false)
    else
      raise ArgumentError, 'Für diese Art von Meldung gibt es keine automatische Korrektur.'
    end
  end

  def update_record(record, serializer, action, attributes)
    before_hash = serialize_for_log(record, serializer)
    record.update!(attributes)
    log_change(record, serializer:, action:, before_hash:)
  end

  def merge(source, target, serializer)
    log_change(target, serializer:, action: 'merge', before_hash: serialize_for_log(source, serializer))
    EntityMerge.merge!(source, target, always: params[:always].present?)
  end
end
