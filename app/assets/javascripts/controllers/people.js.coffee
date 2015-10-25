$ () ->
  new SortTable(selector: ".datatable-people", direction: 'asc')
  new SortTable(selector: ".datatable-person-scores")
  new SortTable(selector: ".datatable-team-mates", sortCol: 1, noSorting: 'last')