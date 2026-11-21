# frozen_string_literal: true

class Backend::ImportRequestsController < Backend::BackendController
  include Backend::ImportCompetitionSelection

  backend_actions clean_cache_disabled: true
  skip_before_action :preauthorize_action, only: %i[decide_login assign_competition transfer_files]

  default_form do |f|
    f.fields_for :import_request_files do
      f.input :file, as: :file_preview
    end
    f.input :url
    f.input :date, html5: true
    f.association :place, as: :association_select
    f.association :event, as: :association_select
    f.input :description
    if can?(:update, resource)
      f.association :edit_user, collection: AdminUser.admins.filter_collection
      f.input :finished, as: :boolean
    end
  end

  default_index do |i|
    i.col :date
    i.col :place, sortable: { place: :name }
    i.col :event, sortable: { event: :name }
    i.col :description
    i.col :finished_at
    i.col :created_at
  end

  def new
    form_resource.import_request_files.build
    super
  end

  # step 1 of the import: store the competition (blank to choose another one)
  def assign_competition
    import_request = ImportRequest.find(params[:id])
    authorize!(:update, import_request)
    import_request.update!(competition: Competition.find_by(id: params[:competition_id]))
    redirect_to backend_import_request_path(import_request)
  end

  # all not yet transferred PDFs to the competition, with the disciplines guessed from the file names
  def transfer_files
    import_request = ImportRequest.find(params[:id])
    authorize!(:update, import_request)
    authorize!(:create, CompetitionFile)
    competition = import_request.competition || raise(ActiveRecord::RecordNotFound)
    files = import_request.import_request_files.select { it.pdf? && !it.transfered? }
    ImportRequestFile.transaction do
      files.each do |file|
        file.update!(transfer_competition_id: competition.id, transfer_keys_string: file.guessed_keys.join(','))
      end
    end
    Caching::Cleaner.new.save
    redirect_to backend_import_request_path(import_request), notice: "#{files.size} PDFs übertragen."
  end

  def decide_login
    redirect_to action: :new if current_login.present?
    session[:requested_url_before_login] = request.fullpath
  end

  protected

  def build_resource
    super.tap { |r| r.admin_user = current_admin_user }
  end

  def after_create
    ImportRequestMailer.with(import_request: resource).new_request.deliver_later
    super
  end

  def show_associations?
    false
  end

  # the competition is stored in the import request (not in the session like the backend imports)
  def import_competition
    @import_competition ||= resource&.competition&.decorate
  end
end
