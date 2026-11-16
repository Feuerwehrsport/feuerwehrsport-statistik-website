#= require classes/SortTable

# sortable tables of the round page; editing entries: stimulus series-participations
Fss.ready 'backend/series/round', ->
  new SortTable({ selector: '.datatable-scores', direction: 'asc' })
