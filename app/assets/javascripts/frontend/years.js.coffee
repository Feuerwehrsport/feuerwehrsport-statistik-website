#= require classes/Fss
#= require classes/SortTable

Fss.ready 'year', ->
  new SortTable({ selector: '.datatable-years' })
  new SortTable({ selector: '.datatable-year-competitons' })
  new SortTable({ selector: '.datatable-best-performance', direction: 'asc' })
  new SortTable({ selector: '.datatable-best-scores', direction: 'asc' })
  new SortTable({ selector: '.datatable-years-inprovements', sortCol: 1 })
