$ () ->
  new SortTable(selector: ".datatable-competitons", direction: 'desc')
  new SortTable(selector: ".datatable.scores-group", direction: 'desc', sortCol: 1)
  new SortTable(selector: ".datatable.scores-zk", direction: 'desc', sortCol: 4)
  new SortTable(selector: ".datatable.scores-single", direction: 'desc', sortCol: 3)