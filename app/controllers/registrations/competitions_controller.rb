class Registrations::CompetitionsController < Registrations::BaseController
  default_actions
  member_actions :add_team, :add_person, :show, :edit, :destroy

  filter_index do |by|
    by.scope :past_records
  end

  default_index do |t|
    t.col :date
    t.col :name
    t.col :place
  end

  default_form do |f|
    f.input :name
    f.input :date
    f.input :place
    f.input :description, as: :wysiwyg
    f.association :admin_user if can?(:manage, AdminUser)
    f.fields_for :assessments do
      f.input :discipline, as: :hidden
      f.input :gender, as: :hidden
      f.input :name, as: :hidden
    end
    f.value :assessments_overview
    f.input :published
  end

  def create
    if params[:from_template].present?
      form_resource.assign_attributes(resource_params)
      render :new
    else
      super
    end
  end

  def new
    redirect_to action: :new_select_template
  end

  def new_select_template
    @types = [
      build_template('Löschangriff-Wettkampf', [%i[la male], %i[la female]]),
      build_template('Löschangriff-Wettkampf mit Jugend', [
                       %i[la male], %i[la female],
                       [:la, :male, 'Jugend'], [:la, :female, 'Jugend']
                     ]),
      build_template('Hindernisbahn-Wettkampf', [%i[hb male], %i[hb female]]),
      build_template('Hakenleitersteigen-Wettkampf', [%i[hl male], %i[hl female]]),
      build_template('Deutschland-Cup', [
                       %i[la male], %i[la female],
                       %i[fs male], %i[fs female],
                       %i[hb male], %i[hb female],
                       %i[hl male], %i[hl female],
                       %i[gs female]
                     ], person_tags: 'U20'),
      build_template('Leere Vorlage', []),
    ]
  end

  def show
    super

    @teams = {}
    @people = {}
    @people_count = {}
    %i[female male].each do |gender|
      @teams[gender] = resource.teams.gender(gender).decorate
      @people[gender] = resource.people.gender(gender).where(team_id: nil).accessible_by(current_ability).decorate
      @people_count[gender] = resource.people.gender(gender).where(team_id: nil).count
    end

    format = request.format.to_sym
    return unless format.in?(%i[wettkampf_manager_import xlsx pdf])
    authorize!(:export, resource)
    response.headers['Content-Disposition'] = "attachment; filename=\"#{resource.to_s.parameterize}.#{format}\""
    return if format != :wettkampf_manager_import
    render text: resource.to_serializer.to_json
  end

  def slug_handle
    competition = Registrations::Competition.find_by!(slug: params[:slug])
    redirect_to action: :show, id: competition.id
  end

  protected

  def page_size
    15
  end

  def build_resource
    resource_class.new(admin_user: current_admin_user, published: true)
  end

  private

  def build_template(name, assessments, options = {})
    resource = build_resource
    resource.assign_attributes(options.merge(name: name))
    assessments.each do |discipline, gender, assessment_name|
      opts = { discipline: discipline, gender: gender }
      opts[:name] = assessment_name if assessment_name.present?
      resource.assessments.build(opts)
    end
    resource
  end
end
