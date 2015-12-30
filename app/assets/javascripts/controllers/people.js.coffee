$ () ->
  new SortTable(selector: ".datatable-people", direction: 'asc')
  new SortTable(selector: ".datatable-person-scores")
  new SortTable(selector: ".datatable-team-mates", sortCol: 1, noSorting: 'last')


  $('#add-person').click () ->
    Fss.checkLogin () ->
      Fss.getResources 'nations', (nations) ->
        genderOptions = [
          { value: 'male', display: 'männlich'}
          { value: 'female', display: 'weiblich'}
        ]
        nationOptions = nations.map (nation) ->
          { value: nation.id, display: nation.name }

        FssWindow.build('Person hinzufügen')
        .add(new FssFormRowText('first_name', 'Vorname'))
        .add(new FssFormRowText('last_name', 'Nachname'))
        .add(new FssFormRowSelect('gender', 'Geschlecht', null, genderOptions))
        .add(new FssFormRowSelect('nation_id', 'Nation', null, nationOptions))
        .on('submit', (personData) ->
          Fss.ajaxReload 'POST', 'people', person: personData
        )
        .open()
