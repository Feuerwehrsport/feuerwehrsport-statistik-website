#= require classes/Fss
#= require classes/SortTable

Fss.ready 'series/assessment', ->
  new SortTable({ selector: '.datatable-scores', direction: 'asc' })
