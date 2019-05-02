#= require dataTables/jquery.dataTables
#= require dataTables/jquery.dataTables.bootstrap
#= require dataTables/jquery.dataTables.german
#= require dataTables/jquery.dataTables.timeSorting

M3.ready ->
  $('.datatable-serverside').each ->
    dataTableOptions = {
      bAutoWidth: false
      bPaginate: true
      iDisplayLength: 10
      serverSide: true
    }
    table = $(this)
    dataTableOptions = $.extend({}, dataTableOptions, table.data('datatable-options'))
    dataTableOptions.ajax.data = (data) ->
      delete data.columns
      data
    table.dataTable(dataTableOptions)
