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
#= require classes/ConfirmFssWindow
#= require classes/EventHandler
#= require classes/Fss
#= require classes/FssFormRow
#= require classes/FssMap
#= require classes/FssWindow
#= require classes/SortTable
#= require classes/WaitFssWindow
#= require classes/WarningFssWindow

dataTableWrapper = (className, label, callback) ->
  $("table.#{className}").each () ->
    table = $(this)
    wrapper = table.closest('.dataTables_wrapper')
    buttonWrapper = wrapper.find('.change-table-wrapper')
    button = $('<div/>').addClass('btn btn-info').text(label).hide().appendTo(buttonWrapper).click () -> 
      button.hide()
      table.dataTable().$('tr').each () ->
        tr = $(this)
        text = tr.find('.time-col').text()
        button = $('<div/>').addClass('glyphicon glyphicon-pencil btn btn-default btn-xs').text(" #{text}")
        tr.find('.time-col').text("").append(button)
        button
          .attr('title', label)
          .click () ->
            callback(tr.data('score-id'))
    button.fadeIn()


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
        Fss.ajaxReload 'POST', 'links', link: data, log_action: 'add-link'
      )
      .open()

  $('.report-link').click () ->
    element = $(this).closest('h4')

    Fss.checkLogin () ->
      new ConfirmFssWindow('Link melden', "Soll der Link »#{element.find('a').text()}« als defekt gemeldet werden?", (data) ->
        Fss.changeRequest('report-link', link_id: element.data('link-id'))
      )

  setTimeout( () ->
    dataTableWrapper 'change-position', "Positionen bearbeiten", (scoreId) ->
      Fss.teamMates(scoreId)
    dataTableWrapper 'change-team', "Mannschaften bearbeiten", (scoreId) ->
      Fss.checkLogin () ->
        Fss.getResources 'teams', (teams) ->
          Fss.getResource 'scores', scoreId, (score) ->
            teamOptions = [{value: 'NULL', display: ''}]
            for team in teams
              teamOptions.push({ value: team.id, display: team.name })
            numbers = [
              { display: 'Außer der Wertung', value: -6 },
              { display: 'Achtelfinale', value: -5 },
              { display: 'Viertelfinale', value: -4 },
              { display: 'Halbfinale', value: -3 },
              { display: 'Finale', value: -2 },
              { display: 'Einzelstarter', value: -1 },
              { display: 'Mannschaft 1', value: 0 },
              { display: 'Mannschaft 2', value: 1 },
              { display: 'Mannschaft 3', value: 2 },
              { display: 'Mannschaft 4', value: 3 },
              { display: 'Mannschaft 5', value: 4 }
            ]

            w = FssWindow.build('Wertungszeit zuordnen')
            .add(new FssFormRowDescription("Sie ordnen der Person <strong>#{score.person}</strong> bei diesem Wettkampf einer Mannschaft zu."))
            .add(new FssFormRowSelect('team_id', 'Mannschaft: ', score.team_id, teamOptions))

            for similarScore in score.similar_scores
              w.add(new FssFormRowSelect(
                "score_#{similarScore.id}",
                "#{similarScore.discipline}: #{similarScore.second_time}",
                similarScore.team_number,
                numbers
              ))

            w.on('submit', (data) ->
              Fss.reloadOnArrayReady score.similar_scores, (score, success) ->
                scoreData = 
                  team_id: data.team_id
                  team_number: data["score_#{score.id}"]
                Fss.put "scores/#{score.id}", score: scoreData, log_action: "update-team", success
            ).open()
  , 1500)