class Registrations::CompetitionsController < Registrations::BaseController
  default_actions
  member_actions :add_team, :add_person, :show, :edit, :destroy

  default_index do |t|
    t.col :date
    t.col :name
    t.col :place
  end

  default_form do |f|
    f.inputs 'Allgemeine Information' do
      f.input :name
      f.input :date
      f.input :place
      f.input :description, as: :wysiwyg
      f.association :admin_user if can?(:manage, AdminUser)
    end
    f.inputs 'Anmeldeinformationen' do
      f.input :open_at
      f.input :close_at
    end
    f.inputs 'Zusätzliche Angaben für Anmeldende' do
      f.input :person_tags
      f.input :team_tags
    end
    f.input :slug
    f.input :published
    f.input :group_score

    f.fields_for :competition_assessments do
      f.input :id
      f.input :discipline
      f.input :gender
      f.input :name
      f.input :_destroy
    end
  end

  def publishing
    resource_instance.slug = resource_instance.to_s.parameterize if resource_instance.slug.blank?
  end

  def new_select_template
    la = build_resource.decorate
    la.name = 'Löschangriff-Wettkampf'
    la.competition_assessments.build(discipline: :la, gender: :male)
    la.competition_assessments.build(discipline: :la, gender: :female)

    la_youth = build_resource.decorate
    la_youth.name = 'Löschangriff-Wettkampf mit Jugend'
    la_youth.competition_assessments.build(discipline: :la, gender: :male)
    la_youth.competition_assessments.build(discipline: :la, gender: :female)
    la_youth.competition_assessments.build(discipline: :la, gender: :male, name: 'Jugend')
    la_youth.competition_assessments.build(discipline: :la, gender: :female, name: 'Jugend')

    hb = build_resource.decorate
    hb.name = 'Hindernisbahn-Wettkampf'
    hb.competition_assessments.build(discipline: :hb, gender: :male)
    hb.competition_assessments.build(discipline: :hb, gender: :female)

    hl = build_resource.decorate
    hl.name = 'Hakenleitersteigen-Wettkampf'
    hl.competition_assessments.build(discipline: :hl, gender: :male)
    hl.competition_assessments.build(discipline: :hl, gender: :female)

    dcup = build_resource.decorate
    dcup.name = 'Deutschland-Cup'
    dcup.person_tags = 'U20'
    dcup.competition_assessments.build(discipline: :la, gender: :male)
    dcup.competition_assessments.build(discipline: :la, gender: :female)
    dcup.competition_assessments.build(discipline: :fs, gender: :male)
    dcup.competition_assessments.build(discipline: :fs, gender: :female)
    dcup.competition_assessments.build(discipline: :hb, gender: :male)
    dcup.competition_assessments.build(discipline: :hb, gender: :female)
    dcup.competition_assessments.build(discipline: :hl, gender: :male)
    dcup.competition_assessments.build(discipline: :hl, gender: :female)
    dcup.competition_assessments.build(discipline: :gs, gender: :female)

    empty = build_resource.decorate
    empty.name = 'Leere Vorlage'
    @types = [la, la_youth, hb, hl, dcup, empty]
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
    if format.in?(%i[wettkampf_manager_import xlsx pdf])
      authorize!(:export, resource)
      response.headers['Content-Disposition'] = "attachment; filename=\"#{resource.to_s.parameterize}.#{format}\""
      if format == :wettkampf_manager_import
        render text: resource.to_serializer.to_json
      end
    end
  end

  def slug_handle
    competition = Registrations::Competition.find_by!(slug: params[:slug])
    redirect_to action: :show, id: competition.id
  end

  def update
    @publishing_form = params[:publishing].present?
    super
  end

  protected

  def build_resource
    resource_class.new(admin_user: current_admin_user)
  end
end
