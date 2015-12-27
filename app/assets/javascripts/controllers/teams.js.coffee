$ () ->
  new SortTable(selector: ".datatable-teams", noSorting: 0, sortCol: 1, direction: 'asc')
  new SortTable(selector: ".datatable-team-members", direction: 'asc')
  new SortTable(selector: ".datatable-team-competitions")
  new SortTable(selector: ".datatable-group-assessments", noSorting: [5, 6])
  new SortTable(selector: ".datatable-group-disciplines")


  if $('#team-map').length > 0
    elem = $('#team-map')
    FssMap.loadStyle () ->
      red = elem.data('map').red
      map = FssMap.getMap('team-map', red.latlon)
      L.marker(red.latlon, icon: FssMap.redIcon()).bindPopup(red.popup).addTo(map)

  $('#add-team').click (ev) ->
    ev.preventDefault()
    Fss.checkLogin () ->
      options = [
        { value: 'team', display: 'Zusammenschluss (Team)'}
        { value: 'fire_station', display: 'Einzelne Feuerwehr'}
      ]

      FssWindow.build('Mannschaft anlegen')
      .add(new FssFormRowText('name', 'Name'))
      .add(new FssFormRowText('shortcut', 'Abkürzung'))
      .add(new FssFormRowDescription('Kurzer Name (maximal 10 Zeichen)'))
      .add(new FssFormRowSelect('status', 'Typ der Mannschaft', null, options))
      .on('submit', (data) ->
        Fss.postReload 'teams', team: data
      )
      .open()