teamEditWindow = (title, data, submit) ->
  options = [
    { value: 'team', display: 'Zusammenschluss (Team)'}
    { value: 'fire_station', display: 'Einzelne Feuerwehr'}
  ]

  FssWindow.build(title)
  .add(new FssFormRowText('name', 'Name', data.name))
  .add(new FssFormRowText('shortcut', 'Abkürzung', data.shortcut))
  .add(new FssFormRowDescription('Kurzer Name (maximal 10 Zeichen)'))
  .add(new FssFormRowSelect('status', 'Typ der Mannschaft', data.status, options))
  .on('submit', submit)
  .open()

addLogo = (teamId) ->
  Fss.checkLogin () ->
    FssWindow.build('Neues Logo')
    .add(new FssFormRowDescription('Bitte wählen Sie ein neues Logo aus:'))
    .add(new FssFormRowFile('logo_files'))
    .on('submit', (data) ->
      if data.logo_files.length is 0
        new WarningFssWindow("Sie haben keine Datei ausgewählt.")
        return
      Fss.changeRequest('team-logo', team_id: teamId, data.logo_files)
    )
    .open()

marker = null
mapLoaded = false
loadMap = (draggableMarker=false) ->
  return if $('#team-map').length is 0

  elem = $('#team-map').hide()
  red = elem.data('map').red
  if red || draggableMarker
    elem.show()
    w = new WaitFssWindow() if draggableMarker
    FssMap.loadStyle () ->
      w.close() if draggableMarker
      
      latlon = [FssMap.lat, FssMap.lon]
      latlon = red.latlon if red

      map = FssMap.getMap('team-map', latlon) unless mapLoaded
      mapLoaded = true

      marker = L.marker(latlon, icon: FssMap.redIcon()).addTo(map) if marker is null
      marker.bindPopup(red.popup) if red
      marker.dragging.enable() if draggableMarker

  if draggableMarker
    actions = $('.team-map-actions')
    actions.children().remove()
    $('<div/>').addClass('btn btn-primary').text("Speichern").appendTo(actions).click () ->
      Fss.checkLogin () ->
        Fss.ajaxReload 'PUT', "teams/#{elem.data('team-id')}", 
          team:
            latitude: marker.getLatLng().lat
            longitude: marker.getLatLng().lng
          log_action: "update-geo-position"

$ () ->
  new SortTable(selector: ".datatable-teams", noSorting: 0, sortCol: 1, direction: 'asc')
  new SortTable(selector: ".datatable-team-members", direction: 'asc')
  new SortTable(selector: ".datatable-team-competitions")
  new SortTable(selector: ".datatable-group-assessments", noSorting: [5, 6])
  new SortTable(selector: ".datatable-group-disciplines")

  loadMap()

  $('#add-team').click () ->
    Fss.checkLogin () ->
      teamEditWindow 'Mannschaft anlegen', {}, (data) ->
        Fss.ajaxReload 'POST', 'teams', team: data, log_action: "add-team"

  $('.upload-logo').click () ->
    addLogo($(this).data('team-id'))

  $('#add-geo-position').click () ->
    loadMap(true)

  $('#add-change-request').click () ->
    teamId = $(this).data('team-id')

    Fss.checkLogin () ->
      options = [
        { value: 'merge', display: 'Team ist doppelt vorhanden'},
        { value: 'correction', display: 'Team ist falsch geschrieben'},
        { value: 'logo', display: 'Neues Logo hochladen'},
        { value: 'map', display: 'Kartenposition ändern'},
        { value: 'other', display: 'Etwas anderes'}
      ]
      FssWindow.build('Auswahl des Fehlers')
      .add(new FssFormRowDescription('Bitte wählen Sie das Problem aus:'))
      .add(new FssFormRowRadio('what', 'Was ist passiert?', null, options))
      .on('submit', (data) ->
        selected = data.what

        if selected is 'correction'
          Fss.getResource 'teams', teamId, (team) ->
            teamEditWindow 'Mannschaft korrigieren', team, (data) ->
              Fss.changeRequest('team-correction', team_id: teamId, team: data)
        else if selected is 'merge'
          Fss.getResources 'teams', (teams) ->
            teamOptions = []
            for team in teams
              teamOptions.push(value: team.id, display: team.name) if team.id isnt teamId

            FssWindow.build('Mannschaft zusammenführen')
            .add(new FssFormRowDescription('Bitte wählen Sie das korrekte Team aus:'))
            .add(new FssFormRowSelect('correct_team_id', 'Richtiges Team:', null, teamOptions))
            .on('submit', (data) ->
              Fss.changeRequest('team-merge', team_id: teamId, correct_team_id: data.correct_team_id)
            )
            .open()
        else if selected is 'other'
          FssWindow.build('Fehler beschreiben')
          .add(new FssFormRowDescription('Bitte beschreiben Sie das Problem:'))
          .add(new FssFormRowTextarea('description', 'Beschreibung', ''))
          .on('submit', (data) ->
            Fss.changeRequest('team-other', team_id: teamId, description: data.description)
          )
          .open()
        else if selected is 'logo'
          addLogo(teamId)
        else if selected is 'map'
          location.hash = '#toc-karte'
          loadMap(true)
      )
      .open()