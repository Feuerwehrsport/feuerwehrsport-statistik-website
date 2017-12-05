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
    f.inputs 'Allgemeine Information' do
      f.input :name
      f.input :date
      f.input :place
      f.input :description, as: :wysiwyg
      f.association :admin_user if can?(:manage, AdminUser)
    end
  end

  def new
    redirect_to action: :new_select_template
  end

  def new_select_template
    la = build_resource
    la.name = 'Löschangriff-Wettkampf'
    la.assessments.build(discipline: :la, gender: :male)
    la.assessments.build(discipline: :la, gender: :female)

    la_youth = build_resource
    la_youth.name = 'Löschangriff-Wettkampf mit Jugend'
    la_youth.assessments.build(discipline: :la, gender: :male)
    la_youth.assessments.build(discipline: :la, gender: :female)
    la_youth.assessments.build(discipline: :la, gender: :male, name: 'Jugend')
    la_youth.assessments.build(discipline: :la, gender: :female, name: 'Jugend')

    hb = build_resource
    hb.name = 'Hindernisbahn-Wettkampf'
    hb.assessments.build(discipline: :hb, gender: :male)
    hb.assessments.build(discipline: :hb, gender: :female)

    hl = build_resource
    hl.name = 'Hakenleitersteigen-Wettkampf'
    hl.assessments.build(discipline: :hl, gender: :male)
    hl.assessments.build(discipline: :hl, gender: :female)

    dcup = build_resource
    dcup.name = 'Deutschland-Cup'
    dcup.person_tags = 'U20'
    dcup.assessments.build(discipline: :la, gender: :male)
    dcup.assessments.build(discipline: :la, gender: :female)
    dcup.assessments.build(discipline: :fs, gender: :male)
    dcup.assessments.build(discipline: :fs, gender: :female)
    dcup.assessments.build(discipline: :hb, gender: :male)
    dcup.assessments.build(discipline: :hb, gender: :female)
    dcup.assessments.build(discipline: :hl, gender: :male)
    dcup.assessments.build(discipline: :hl, gender: :female)
    dcup.assessments.build(discipline: :gs, gender: :female)

    empty = build_resource
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

  protected

  def find_collection
    super.future_records.published
  end

  def build_resource
    resource_class.new(admin_user: current_admin_user)
  end
end
