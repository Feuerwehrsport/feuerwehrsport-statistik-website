#= require _main

#= require _datatable_serverside
#= require highcharts/highcharts
#= require highcharts/highcharts-more
#= require classes/SortTable

#= require_tree ./frontend

Highcharts.setOptions({ plotOptions: { series: { animation: false } } })

# callback: called on click (old FssWindow dialogs); urlFor: returns the url of a Hotwire dialog
dataTableWrapper = (className, label, callback, urlFor = null) ->
  $("table.#{className}").each ->
    table = $(this)
    wrapper = table.closest('.dataTables_wrapper')
    buttonWrapper = wrapper.find('.change-table-wrapper')
    button = $('<div/>').addClass('btn btn-info').text(label).hide().appendTo(buttonWrapper).click ->
      button.hide()
      table.dataTable().$('tr').each ->
        tr = $(this)
        text = tr.find('.time-col').text()
        scoreId = tr.data('score-id')
        url = if urlFor? then urlFor(scoreId) else null
        if url
          editButton = $('<a/>').attr('href', url).attr('data-turbo-frame', 'contribution').attr('data-turbo', 'true')
        else
          editButton = $('<div/>').click -> callback(scoreId)
        editButton.addClass('glyphicon glyphicon-pencil btn btn-default btn-xs').text(" #{text}").attr('title', label)
        tr.find('.time-col').text('').append(editButton)
    button.fadeIn()


M3.ready ->
  setTimeout( ->
    dataTableWrapper 'change-position', 'Positionen bearbeiten', (scoreId) ->
      Fss.teamMates(scoreId)
    # the pencil links open the dialog Contributions::ScoreTeamsController
    dataTableWrapper 'change-team', 'Mannschaften bearbeiten', null, (scoreId) ->
      "/contributions/scores/#{scoreId}/team/edit"
  , 1500)

  new SortTable({ selector: '.datatable-unspecified', direction: 'asc' })
