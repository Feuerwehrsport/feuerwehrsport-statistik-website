#= require classes/Fss
#= require classes/SortTable

Fss.ready 'year', ->
  new SortTable(selector: ".datatable-years", direction: 'desc')
  new SortTable(selector: ".datatable-year-competitons", direction: 'desc')
  new SortTable(selector: ".datatable-best-performance", direction: 'asc')
  new SortTable(selector: ".datatable-best-scores", direction: 'asc')