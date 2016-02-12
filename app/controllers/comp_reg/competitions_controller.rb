module CompReg
  class CompetitionsController < CompRegController
    include CRUD::NewAction
    include CRUD::CreateAction
    include CRUD::ShowAction
    include CRUD::IndexAction
    include CRUD::EditAction
    include CRUD::UpdateAction
    include CRUD::DestroyAction

    def new_select_template
      la = build_instance.decorate
      la.name = "Löschangriff-Wettkampf"
      la.competition_assessments.build(discipline: :la, gender: :male)
      la.competition_assessments.build(discipline: :la, gender: :female)

      la_youth = build_instance.decorate
      la_youth.name = "Löschangriff-Wettkampf mit Jugend"
      la_youth.competition_assessments.build(discipline: :la, gender: :male)
      la_youth.competition_assessments.build(discipline: :la, gender: :female)
      la_youth.competition_assessments.build(discipline: :la, gender: :male, name: "Jugend")
      la_youth.competition_assessments.build(discipline: :la, gender: :female, name: "Jugend")

      hb = build_instance.decorate
      hb.name = "Hindernisbahn-Wettkampf"
      hb.competition_assessments.build(discipline: :hb, gender: :male)
      hb.competition_assessments.build(discipline: :hb, gender: :female)

      hl = build_instance.decorate
      hl.name = "Hakenleitersteigen-Wettkampf"
      hl.competition_assessments.build(discipline: :hl, gender: :male)
      hl.competition_assessments.build(discipline: :hl, gender: :female)

      dcup = build_instance.decorate
      dcup.name = "Deutschland-Cup"
      dcup.person_tags = "U20"
      dcup.competition_assessments.build(discipline: :la, gender: :male)
      dcup.competition_assessments.build(discipline: :la, gender: :female)
      dcup.competition_assessments.build(discipline: :fs, gender: :male)
      dcup.competition_assessments.build(discipline: :fs, gender: :female)
      dcup.competition_assessments.build(discipline: :hb, gender: :male)
      dcup.competition_assessments.build(discipline: :hb, gender: :female)
      dcup.competition_assessments.build(discipline: :hl, gender: :male)
      dcup.competition_assessments.build(discipline: :hl, gender: :female)
      dcup.competition_assessments.build(discipline: :gs, gender: :female)

      empty = build_instance.decorate
      empty.name = "Leere Vorlage"
      empty.competition_assessments.build(discipline: :hl, gender: :male)
      empty.competition_assessments.build(discipline: :hl, gender: :female)
      @types = [la, la_youth, hb, hl, dcup, empty]
    end

    def show
      super

      @teams = {}
      @people = {}
      @people_count = {}
      [:female, :male].each do |gender|
        @teams[gender] = resource_instance.object.teams.gender(gender).decorate
        @people[gender] = resource_instance.object.people.gender(gender).where(team_id: nil).accessible_by(current_ability).decorate
        @people_count[gender] = resource_instance.object.people.gender(gender).where(team_id: nil).count
      end

      format = request.format.to_sym
      if format.in?([:wettkampf_manager_import, :xlsx, :pdf])
        authorize!(:export, resource_instance)
        response.headers['Content-Disposition'] = "attachment; filename=\"#{resource_instance.to_s.parameterize}.#{format}\""
        if format == :wettkampf_manager_import
          render text: resource_instance.to_serializer.to_json
        end
      end
    end

    protected

    def permitted_attributes
      super.permit(:name, :place, :date, :description, :open_at, :close_at, :person_tags, :team_tags,
        competition_assessments_attributes: [:id, :discipline, :gender, :name, :_destroy]
      )
    end

    def build_instance
      resource_class.new(admin_user: current_admin_user)
    end
  end
end
