$ () ->
  editPersonParticipation = (title, participation, success) ->
    Fss.getResources 'people', (people) ->
      options = []
      for person in people
        options.push
          value: person.id
          display: "#{person.last_name}, #{person.first_name} (#{person.gender_translated})"
      FssWindow.build(title)
      .add(new FssFormRowSelect('person_id', 'Person', participation.person_id, options))
      .add(new FssFormRowText('rank', 'Platz', participation.rank))
      .add(new FssFormRowText('points', 'Punkte', participation.points))
      .add(new FssFormRowText('time', 'Zeit', participation.time))
      .on('submit', success)
      .open()

  editTeamParticipation = (title, participation, success) ->
    Fss.getResources 'series/team_assessments', { round_id: roundId }, (assessments) ->
      Fss.getResources 'teams', (teams) ->
        personOptions = []
        for team in teams
          personOptions.push
            value: team.id
            display: "#{team.name}"
        assessmentOptions = []
        for assessment in assessments
          assessmentOptions.push
            value: assessment.id
            display: "#{assessment.name}"
        FssWindow.build(title)
        .add(new FssFormRowSelect('team_id', 'Mannschaft', participation.team_id, personOptions))
        .add(new FssFormRowSelect('assessment_id', 'Wertung', participation.assessment_id, assessmentOptions))
        .add(new FssFormRowText('team_number', 'Nummer', participation.team_number))
        .add(new FssFormRowText('rank', 'Platz', participation.rank))
        .add(new FssFormRowText('points', 'Punkte', participation.points))
        .add(new FssFormRowText('time', 'Zeit', participation.time))
        .on('submit', success)
        .open()

  upDown = (id, data) ->
    new ConfirmFssWindow 'Ändern?', "Points: #{data.points}; Rank: #{data.rank}", () ->
      Fss.ajaxReload("PUT", "series/participations/#{id}", series_participation: data)

  roundId = $('#edit-series-participations').data('round-id')
  $('#edit-series-participations .series-participation').each () ->
    $(@).addClass("btn btn-default btn-xs")

  $('.add-person-participation').click () ->
    assessmentId = $(@).data('assessment-id')
    cupId = $(@).data('cup-id')
    editPersonParticipation 'Teilnahme hinzufügen', {}, (data) ->
      data.assessment_id = assessmentId
      data.cup_id = cupId
      Fss.ajaxReload("POST", "series/participations", series_participation: data)

  $('.add-team-participation').click () ->
    cupId = $(@).data('cup-id')
    editTeamParticipation 'Teilnahme hinzufügen', {}, (data) ->
      data.cup_id = cupId
      Fss.ajaxReload("POST", "series/participations", series_participation: data)

  $(document).on 'click', '#edit-series-participations .series-participation', () ->
    id = $(@).data('id')
    Fss.getResource 'series/participations', id, (participation) ->
      w = FssWindow.build('Serienteilnahme')
      change = $('<button/>').text('Ändern').on('click', (e) ->
        e.preventDefault()
        w.close()
        if participation.participation_type == 'person'
          editPersonParticipation 'Teilnahme korrigieren', participation, (data) ->
            Fss.ajaxReload('PUT', "series/participations/#{id}", series_participation: data)
        else
          editTeamParticipation 'Teilnahme korrigieren', participation, (data) ->
            Fss.ajaxReload('PUT', "series/participations/#{id}", series_participation: data)
      )
      up = $('<button/>').text('↑').on('click', (e) ->
        e.preventDefault()
        w.close()
        data =
          rank: participation.rank - 1
          points: participation.points + 1
        data.rank = 1 if data.rank < 1
        upDown(id, data)
      )
      down = $('<button/>').text('↓').on('click', (e) ->
        e.preventDefault()
        w.close()
        data =
          rank: participation.rank + 1
          points: participation.points - 1
        data.points = 0 if data.points < 0
        upDown(id, data)
      )
      destroy = $('<button/>').text('Löschen').on('click', (e) ->
        e.preventDefault()
        w.close()
        new ConfirmFssWindow "Löschen?", "Diesen Eintrag wirklich löschen?", () ->
          Fss.ajaxReload("DELETE", "series/participations/#{id}", {})
      )
      cancel = $('<button/>').text('Abbrechen').on('click', (e) ->
        e.preventDefault()
        w.close()
      )
      w.add((new FssFormRow(change, up, down, destroy, cancel)).addClass('submit-row'))
      w.open()

  new SortTable(selector: ".datatable-scores", direction: 'asc')


  classNameOptions = ->
    teamClassNames = $('#create-round').data('class-names')
    options = []
    for teamClassName in teamClassNames
      options.push
        value: teamClassName
        display: teamClassName
    options

  $('#create-round').click ->
    FssWindow.build('Wettkampfserie hinzufügen')
    .add(new FssFormRowText('name', 'Name'))
    .add(new FssFormRowText('year', 'Jahr'))
    .add(new FssFormRowSelect('aggregate_type', 'Klasse', null, classNameOptions()))
    .add(new FssFormRowCheckbox('official', 'Offiziell'))
    .add(new FssFormRowText('full_cup_count', 'Komplett', round.full_cup_count))
    .on('submit', (data) ->
      Fss.ajaxReload('POST', 'series/rounds', series_round: data))
    .open()

  $('a[data-round-id]').each ->
    id = $(@).data('round-id')
    $('<button>').insertAfter($(@)).addClass('btn btn-default btn-xs').text('Edit').click ->
      Fss.getResource 'series/rounds', id, (round) ->
        FssWindow.build('Wettkampfserie bearbeiten')
        .add(new FssFormRowText('name', 'Name', round.name))
        .add(new FssFormRowText('year', 'Jahr', round.year))
        .add(new FssFormRowSelect('aggregate_type', 'Klasse', round.aggregate_type, classNameOptions()))
        .add(new FssFormRowCheckbox('official', 'Offiziell', round.official))
        .add(new FssFormRowText('full_cup_count', 'Komplett', round.full_cup_count))
        .on('submit', (data) ->
          Fss.ajaxReload('PUT', "series/rounds/#{id}", series_round: data))
        .open()