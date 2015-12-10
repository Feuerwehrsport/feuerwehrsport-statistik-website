#= require jquery
#= require jquery_ujs
#= require lib/js_cookie
#= require bootstrap-sprockets
#= require dataTables/jquery.dataTables
#= require dataTables/jquery.dataTables.bootstrap
#= require dataTables/jquery.dataTables.german
#= require dataTables/jquery.dataTables.timeSorting

#= require highcharts/highcharts
#= require highcharts/highcharts-more

#= require classes/AlertFssWindow
#= require classes/BigImage
#= require classes/Charting
#= require classes/ConfirmFssWindow
#= require classes/EventHandler
#= require classes/Fss
#= require classes/FssFormRow
#= require classes/FssMap
#= require classes/FssWindow
#= require classes/SortTable
#= require classes/WaitFssWindow
#= require classes/WarningFssWindow


$ ->
  $('.add-link').click () ->
    element = $(this)

    Fss.checkLogin () ->
      FssWindow.build('Link hinzufügen')
      .add(new FssFormRowText('label', 'Name'))
      .add(new FssFormRowText('url', 'Link', 'http://'))
      .on('submit', (data) ->
        data.url = data.url.replace(/^http:\/\/(https?:\/\/)/, "$1")
        data.url = "http://#{data.url}" unless data.url.match(/^https?:\/\//)
        data.linkable_id = element.data('linkable-id')
        data.linkable_type = element.data('linkable-type')
        Fss.postReload 'links', link: data
      )
      .open()

  $('.report-link').click () ->
    debugger