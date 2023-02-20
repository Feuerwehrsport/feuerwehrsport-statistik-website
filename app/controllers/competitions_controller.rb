# frozen_string_literal: true

class CompetitionsController < ResourceController
  include DatatableSupport
  resource_actions :show, :index, cache: %i[show index]
  map_support_at :show

  datatable(:index, :competitions, Competition, collection: -> { Competition.includes(:place, :event) }) do |t|
    t.col(:date_iso, class: 'col-10', sortable: :date, default_order: :desc)
    t.col(:linked_name, class: 'col-40 info-link', searchable: [{ event: :name }, { place: :name }, :name],
                        sortable: false)
    t.col(:hb_female, searchable: false, class: 'hidden-xs', th_class: 'small col-5 hidden-xs')
    t.col(:hb_male, searchable: false, class: 'hidden-xs', th_class: 'small col-5 hidden-xs')
    t.col(:hl_female, searchable: false, class: 'hidden-xs', th_class: 'small col-5 hidden-xs')
    t.col(:hb_male, searchable: false, class: 'hidden-xs', th_class: 'small col-5 hidden-xs')
    t.col(:gs, searchable: false, class: 'hidden-xs', th_class: 'small col-5 hidden-xs')
    t.col(:fs_female, searchable: false, class: 'hidden-xs', th_class: 'small col-5 hidden-xs')
    t.col(:fs_male, searchable: false, class: 'hidden-xs', th_class: 'small col-5 hidden-xs')
    t.col(:la_female, searchable: false, class: 'hidden-xs', th_class: 'small col-5 hidden-xs')
    t.col(:la_male, searchable: false, class: 'hidden-xs', th_class: 'small col-5 hidden-xs')
  end

  def index
    @chart = Chart::CompetitionsScoreOverview.new(competitions: Competition.all, context: view_context)
    @competitions_discipline_overview = Calculation::CompetitionsScoreOverview.new(Competition.pluck(:id)).disciplines
  end

  def show
    @calc = Calculation::Competition.new(resource, view_context)
  end
end
