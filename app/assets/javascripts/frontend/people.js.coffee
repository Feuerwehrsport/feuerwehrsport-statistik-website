#= require classes/Fss
#= require classes/SortTable

Fss.ready 'pe', ->
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

  $('#add-change-request').click () ->
    personId = $(this).data('person-id')
    Fss.checkLogin () ->
      options = [
        { value: 'wrong', display: 'Person ist falsch geschrieben'}
        { value: 'nation', display: 'Person ist falscher Nation zugeordnet'}
        { value: 'other', display: 'Etwas anderes'}
      ]
      FssWindow.build('Auswahl des Fehlers')
      .add(new FssFormRowDescription('Bitte wählen Sie das Problem aus:'))
      .add(new FssFormRowRadio('what', 'Was ist passiert?', null, options))
      .on('submit', (data) ->
        selected = data.what
        if selected is 'wrong'
          options = [
            { value: 'merge', display: 'Richtige Schreibweise auswählen (für Administrator <i>VIEL</i> einfacher)'}
            { value: 'correction', display: 'Selbst korrekte Schreibweise hinzufügen'}
          ]
          FssWindow.build('Korrektur des Fehlers')
          .add(new FssFormRowDescription('Bitte wählen Sie die Korrekturmethode aus:'))
          .add(new FssFormRowRadio('what', 'Korrektur wählen', null, options))
          .on('submit', (data) ->
            selected = data.what
            if selected is 'correction'
              Fss.getResource 'people', personId, (person) ->
                FssWindow.build('Namen korrigieren')
                .add(new FssFormRowDescription('Bitte korrigieren Sie den Namen:'))
                .add(new FssFormRowText('first_name', 'Vorname', person.first_name))
                .add(new FssFormRowText('last_name', 'Nachname', person.last_name))
                .on('submit', (data) ->
                  Fss.changeRequest("person-correction", person_id: personId, person: data)
                )
                .open()
            else if selected is 'merge'
              Fss.getResources 'people', (people) ->
                options = []
                for person in people
                  continue if person.id is personId
                  options.push
                    value: person.id
                    display: "#{person.last_name}, #{person.first_name} (#{person.gender_translated})"

                FssWindow.build('Namen korrigieren')
                .add(new FssFormRowDescription('Bitte wählen Sie die korrekte Person aus:'))
                .add(new FssFormRowSelect('person_id', 'Richtige Person', null, options))
                .on('submit', (data) ->
                  Fss.changeRequest("person-merge", person_id: personId, correct_person_id: data.person_id)
                )
                .open()
            )
            .open()
        else if selected is 'other'
          FssWindow.build('Fehler beschreiben')
          .add(new FssFormRowDescription('Bitte beschreiben Sie das Problem:'))
          .add(new FssFormRowTextarea('description', 'Beschreibung', ''))
          .on('submit', (data) ->
            Fss.changeRequest("person-other", person_id: personId, description: data.description)
          )
          .open()
        else if selected is 'nation'
          Fss.getResources 'nations', (nations) ->
            nationOptions = nations.map (nation) ->
              { value: nation.id, display: nation.name }

            FssWindow.build('Andere Nation')
              .add(new FssFormRowDescription('Bitte wählen Sie die richtige Nation:'))
              .add(new FssFormRowSelect('nation_id', 'Nation', null, nationOptions))
              .on('submit', (data) ->
                Fss.changeRequest("person-change-nation", person_id: personId, nation_id: data.nation_id)
              )
            .open()
      )
      .open()