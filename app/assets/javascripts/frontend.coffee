#= require _main

#= require _datatable_serverside
#= require highcharts/highcharts
#= require highcharts/highcharts-more
#= require classes/SortTable

#= require_tree ./frontend

Highcharts.setOptions({ plotOptions: { series: { animation: false } } })

# edit mode of a table: the time cells become links to a Hotwire dialog (urlFor: score id -> url)
dataTableWrapper = (className, label, urlFor) ->
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
        editButton = $('<a/>').attr('href', urlFor(scoreId))
          .attr('data-turbo-frame', 'contribution').attr('data-turbo', 'true')
        editButton.addClass('glyphicon glyphicon-pencil btn btn-default btn-xs').text(" #{text}").attr('title', label)
        tr.find('.time-col').text('').append(editButton)
    button.fadeIn()


M3.ready ->
  setTimeout( ->
    dataTableWrapper 'change-position', 'Positionen bearbeiten', (scoreId) ->
      "/contributions/group_scores/#{scoreId}/participations/edit"
    # the pencil links open the dialog Contributions::ScoreTeamsController
    dataTableWrapper 'change-team', 'Mannschaften bearbeiten', (scoreId) ->
      "/contributions/scores/#{scoreId}/team/edit"
  , 1500)

  new SortTable({ selector: '.datatable-unspecified', direction: 'asc' })
