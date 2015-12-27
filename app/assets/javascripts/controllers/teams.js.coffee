$ () ->
  new SortTable(noSorting: 0, sortCol: 1, direction: 'asc')
  $('table.change-position').each () ->
    table = $(this)
    wrapper = table.closest('.dataTables_wrapper')
    buttonWrapper = wrapper.find('.change-position-wrapper')
    button = $('<div/>').addClass('btn btn-info').text("Positionen bearbeiten").appendTo(buttonWrapper).click () -> 
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