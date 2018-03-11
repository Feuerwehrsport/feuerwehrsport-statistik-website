#= require dataTables/jquery.dataTables
#= require dataTables/jquery.dataTables.bootstrap
#= require dataTables/jquery.dataTables.german
#= require dataTables/jquery.dataTables.timeSorting

class @SortTable
  @options: {
    selector: '.datatable'
    sortCol: 0
    direction: 'desc'
    noSorting: false
    count: 10
  }

  constructor: (options) ->
    options = $.extend({}, SortTable.options, options)

    dataTableOptions = {
      aaSorting: [[ options.sortCol, options.direction ]]
      bAutoWidth: false
      bPaginate: true
      iDisplayLength: options.count
    }

    if options.noSorting? and options.noSorting is 'last'
      $(options.selector).each ->
        new SortTable($.extend(options, { selector: this, noSorting: $(this).find('th').length - 1 }))
      return
    if options.noSorting?
      options.noSorting = [options.noSorting] unless $.isArray(options.noSorting)

      dataTableOptions.aoColumnDefs = [{
        bSortable: false
        aTargets: options.noSorting
      }]
    $(options.selector).dataTable(dataTableOptions)
