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
      table.children().remove() if result.length > 0
      $.each result, (i, item) ->
        tr = $('<tr/>').appendTo(table)
        $('<td/>').text(item.display_name).appendTo(tr)
        $('<td/>').appendTo(tr).append($('<div/>').addClass('btn btn-default btn-sm').text('Auswählen').click ->
          loadMap(true, [item.lat, item.lon])
        )
    $.getScript("https://nominatim.openstreetmap.org/search?q=#{name}&format=json&json_callback=geoPositionResult")


  $('.wiki-search').each ->
    name = $(@).data('name')
    table = $(@).find('table')

    window.wikiSearchResult = (result) ->
      table.children().remove() if result.query.search.length > 0
      $.each result.query.search, (i, item) ->
        console.log item
        tr = $('<tr/>').appendTo(table)
        $('<td/>').appendTo(tr).append($('<a/>').attr('href', "https://de.wikipedia.org/?curid=#{item.pageid}").text(item.title).attr('target', '_blank'))
        $('<td/>').appendTo(tr).append($('<div/>').html(item.snippet))


    $.getScript("https://de.wikipedia.org/w/api.php?action=query&format=json&list=search&utf8=1&srsearch=#{name}&callback=wikiSearchResult")

