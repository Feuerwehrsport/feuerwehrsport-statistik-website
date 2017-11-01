#= require classes/Fss
#= require classes/SortTable

Fss.ready 'event', ->
  new SortTable(selector: '.datatable-events', direction: 'asc')
  new SortTable(selector: '.datatable-event-competitons', direction: 'desc')