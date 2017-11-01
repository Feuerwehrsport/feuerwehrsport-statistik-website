#= require classes/Fss
#= require classes/SortTable

Fss.ready 'series/round', ->
  new SortTable(selector: '.datatable-extra', direction: 'asc')