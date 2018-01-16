#= require lib/map_utils
#= require lib/team_state_selector

Fss.ready 'backend/unchecked_teams', ->
  action = (btn, params = {}) =>
    new ConfirmFssWindow('Mannschaft zusammenführen?', 'Diese Aktion verändert die Daten!', ->
      params.correct_team_id = $(btn).data('correct-id')
      params.log_action = 'merge'
      Fss.post "teams/#{$(btn).data('id')}/merge", params, ->
        window.location = '/backend/unchecked_teams'
    )    
  $('.merge-team').click( -> action(@))
  $('.always-merge-team').click( -> action(@, always: true ))

  teamStateSelector()

  $('.geo-position').each ->
    name = $(@).data('name')
    id = $(@).data('id')
    table = $(@).find('table')

    window.geoPositionResult = (result) ->
      $.each result, (i, item) ->
        tr = $('<tr/>').appendTo(table)
        $('<td/>').text(item.display_name).appendTo(tr)
        $('<td/>').appendTo(tr).append($('<div/>').addClass('btn btn-default btn-sm').text('Auswählen').click ->
          loadMap(true, [item.lat, item.lon])
        )


    $.getScript("https://nominatim.openstreetmap.org/search?q=#{name}&format=json&json_callback=geoPositionResult")
