class MissingTeam
  constructor: (@name, @callback) ->
  get: () =>
    $('<li/>').text(@name).click () =>
      Fss.checkLogin () =>
        @name = @name.replace(/\sII?$/, '')
        longname = @name
        
        options = [
          { value: 'Team', display: 'Zusammenschluss (Team)'},
          { value: 'Feuerwehr', display: 'Einzelne Feuerwehr'}
        ]

        if @name.match(/^FF/)
          @name = @name.replace(/^FF\s+/, '')
        else
          longname = 'FF '+@name

        FssWindow.build('Mannschaft anlegen')
        .add(new FssFormRowText('name', 'Name', longname))
        .add(new FssFormRowText('short', 'Abkürzung', @name))
        .add(new FssFormRowSelect('type', 'Typ der Mannschaft', 'Feuerwehr', options))
        .on('submit', (data) =>
          Fss.post 'add-team', data, () => 
            @callback()
        )
        .open()