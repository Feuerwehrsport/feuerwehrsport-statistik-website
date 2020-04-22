class TeamsController < ResourceController
  include DatatableSupport
  resource_actions :show, cache: %i[show index]
  map_support_at :show, :index

  datatable(:index, :teams, Team) do |t|
    t.col :image_thumb, label: '', sortable: false, th_class: 'col-5'
    t.col :link, sortable: :name, th_class: 'col-40', searchable: :name
    t.col :shortcut, th_class: 'col-30', searchable: :shortcut
    t.col :human_status, sortable: :status, th_class: 'col-10 small', class: 'small'
    t.col :state, th_class: 'col-10 small'
    t.col :members_count, th_class: 'col-15 small'
    t.col :competitions_count, th_class: 'col-15 small'
  end

  def index
    @charts = Chart::TeamOverview.new(context: view_context)
  end

  def show
    super
    @chart = Chart::TeamShow.new(team: resource.decorate, context: view_context)
    @team_members = resource.members_with_discipline_count.map(&:decorate)
    @team_competitions = resource.competitions_with_discipline_count.map(&:decorate)
    @group_assessments = resource.group_assessments
    @group_disciplines = resource.group_disciplines
    @series_round_structs = {}
    @max_cup_count = {}
    %i[female male].each do |gender|
      @series_round_structs[gender] = Series::Round.for_team(resource.id, gender)
      @max_cup_count[gender] = @series_round_structs[gender].values.flatten.map(&:cups).map(&:count).max
    end
  end
end
