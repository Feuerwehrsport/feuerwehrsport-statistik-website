# frozen_string_literal: true

class CompetitionsController < ResourceController
  include DatatableSupport

  resource_actions :show, :index, cache: %i[show index]

  datatable(:index, :competitions, Competition, collection: -> { Competition.includes(:place, :event) }) do |t|
    t.col(:date_iso, class: 'col-w-10', sortable: :date, default_order: :desc)
    t.col(:linked_name, class: 'col-w-40 info-link', searchable: [{ event: :name }, { place: :name }, :name],
                        sortable: false)
    t.col(:hb_female, searchable: false, class: 'd-none d-sm-table-cell',
                      th_class: 'small col-w-5 d-none d-sm-table-cell')
    t.col(:hb_male, searchable: false, class: 'd-none d-sm-table-cell',
                    th_class: 'small col-w-5 d-none d-sm-table-cell')
    t.col(:hl_female, searchable: false, class: 'd-none d-sm-table-cell',
                      th_class: 'small col-w-5 d-none d-sm-table-cell')
    t.col(:hl_male, searchable: false, class: 'd-none d-sm-table-cell',
                    th_class: 'small col-w-5 d-none d-sm-table-cell')
    t.col(:gs, searchable: false, class: 'd-none d-sm-table-cell', th_class: 'small col-w-5 d-none d-sm-table-cell')
    t.col(:fs_female, searchable: false, class: 'd-none d-sm-table-cell',
                      th_class: 'small col-w-5 d-none d-sm-table-cell')
    t.col(:fs_male, searchable: false, class: 'd-none d-sm-table-cell',
                    th_class: 'small col-w-5 d-none d-sm-table-cell')
    t.col(:la_female, searchable: false, class: 'd-none d-sm-table-cell',
                      th_class: 'small col-w-5 d-none d-sm-table-cell')
    t.col(:la_male, searchable: false, class: 'd-none d-sm-table-cell',
                    th_class: 'small col-w-5 d-none d-sm-table-cell')
  end

  def show
    @calc = Calculation::Competition.new(resource, view_context)
    send_xlsx(Competition::Xlsx.new(resource, @calc)) if request.format.xlsx?
  end
end
