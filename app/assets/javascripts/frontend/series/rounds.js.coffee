#= require classes/Fss
#= require classes/SortTable

Fss.ready 'series/', ->
  new SortTable({ selector: '.datatable-extra', direction: 'asc' })
