#= require classes/Fss
#= require classes/SortTable

Fss.ready 'series/person_assessment', ->
  new SortTable({ selector: '.datatable-scores', direction: 'asc' })
