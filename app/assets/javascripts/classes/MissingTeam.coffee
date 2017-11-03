class @MissingTeam
  constructor: (@name, @callback) ->
  get: () =>
    $('<li/>').text(@name).click () =>
      Fss.checkLogin () =>
        @name = @name.replace(/\sII?$/, '')
        longname = @name

        options = [
          { value: 'team', display: 'Zusammenschluss (Team)'}
          { value: 'fire_station', display: 'Einzelne Feuerwehr'}
        ]

        if @name.match(/^FF/)
          @name = @name.replace(/^FF\s+/, '')
        else
          longname = 'FF '+@name

        FssWindow.build('Mannschaft anlegen')
        .add(new FssFormRowText('name', 'Name', longname))
        .add(new FssFormRowText('shortcut', 'Abkürzung', @name))
        .add(new FssFormRowSelect('status', 'Typ der Mannschaft', 'Feuerwehr', options))
        .on('submit', (data) =>
          Fss.post 'teams', team: data, () => 
            @callback()
        )
        .open()