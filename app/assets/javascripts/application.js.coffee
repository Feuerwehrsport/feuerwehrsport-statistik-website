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
        Fss.ajaxReload 'POST', 'links', link: data
      )
      .open()

  $('.report-link').click () ->
    element = $(this).closest('h4')

    Fss.checkLogin () ->
      new ConfirmFssWindow('Link melden', "Soll der Link »#{element.find('a').text()}« als defekt gemeldet werden?", (data) ->
        Fss.changeRequest('report-link', link_id: element.data('link-id'))
      )

  setTimeout( () ->
    $('table.change-position').each () ->
      table = $(this)
      wrapper = table.closest('.dataTables_wrapper')
      buttonWrapper = wrapper.find('.change-position-wrapper')
      button = $('<div/>').addClass('btn btn-info').text("Positionen bearbeiten").hide().appendTo(buttonWrapper).click () -> 
        button.hide()
        table.dataTable().$('tr').each () ->
          tr = $(this)
          text = tr.find('.time-col').text()
          button = $('<div/>').addClass('glyphicon glyphicon-pencil btn btn-default btn-xs').text(" #{text}")
          tr.find('.time-col').text("").append(button)
          button
            .attr('title', 'Positionen bearbeiten')
            .click () ->
              Fss.teamMates(tr.data('score-id'))
      button.fadeIn()
  , 1500)