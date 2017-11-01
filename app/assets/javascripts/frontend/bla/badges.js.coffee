#= require classes/Fss
#= require classes/SortTable

Fss.ready 'bla/badge', ->
  new SortTable(selector: '.datatable-bla-badges', sortCol: 1)