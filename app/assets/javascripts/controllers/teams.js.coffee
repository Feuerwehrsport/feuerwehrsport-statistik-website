$ () ->
  new SortTable(noSorting: 0, sortCol: 1, direction: 'asc')

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