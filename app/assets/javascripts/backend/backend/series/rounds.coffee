#= require classes/Fss
#= require classes/SortTable

Fss.ready 'backend/series/round', ->
  editPersonParticipation = (title, participation, success) ->
    Fss.getResources 'people', (people) ->
      options = []
      for person in people
        options.push({
          value: person.id
          display: "#{person.last_name}, #{person.first_name} (#{person.gender_translated})"
        })
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
          personOptions.push({ value: team.id, display: "#{team.name}" })
        assessmentOptions = []
        for assessment in assessments
          assessmentOptions.push({ value: assessment.id, display: "#{assessment.name}" })
        genderOptions = [
          { value: 0, display: "weiblich" },
          { value: 1, display: "männlich" },
        ]
        FssWindow.build(title)
        .add(new FssFormRowSelect('team_id', 'Mannschaft', participation.team_id, personOptions))
        .add(new FssFormRowSelect('team_assessment_id', 'Wertung', participation.team_assessment_id, assessmentOptions))
        .add(new FssFormRowText('team_number', 'Nummer', participation.team_number))
        .add(new FssFormRowSelect('team_gender', 'Geschlecht', participation.team_gender, genderOptions))
        .add(new FssFormRowText('rank', 'Platz', participation.rank))
        .add(new FssFormRowText('points', 'Punkte', participation.points))
        .add(new FssFormRowText('time', 'Zeit', participation.time))
        .on('submit', success)
        .open()


  roundId = $('#edit-series-participations').data('round-id')
  $('#edit-series-participations .series-participation').each ->
    $(this).addClass('btn btn-default btn-xs')

  $('.add-person-participation').click ->
    assessmentId = $(this).data('assessment-id')
    cupId = $(this).data('cup-id')
    editPersonParticipation 'Teilnahme hinzufügen', {}, (data) ->
      data.person_assessment_id = assessmentId
      data.cup_id = cupId
      Fss.ajaxReload('POST', 'series/person_participations', { series_person_participation: data })

  $('.add-team-participation').click ->
    cupId = $(this).data('cup-id')
    editTeamParticipation 'Teilnahme hinzufügen', {}, (data) ->
      data.cup_id = cupId
      Fss.ajaxReload('POST', 'series/team_participations', { series_team_participation: data })

  $(document).on 'click', '#edit-series-participations .series-participation', ->
    id = $(this).data('id')
    type = $(this).data('type')
    url_path = "series/#{type}_participations"

    changeData = (data) ->
      if type == "person"
        Fss.ajaxReload('PUT', "#{url_path}/#{id}", { series_person_participation: data })
      else if type == "team"
        Fss.ajaxReload('PUT', "#{url_path}/#{id}", { series_team_participation: data })

    upDown = (id, data) ->
      new ConfirmFssWindow 'Ändern?', "Points: #{data.points}; Rank: #{data.rank}", ->
        changeData(data)

    Fss.getResource url_path, id, (participation) ->
      w = FssWindow.build('Serienteilnahme')
      change = $('<button/>').text('Ändern').on('click', (e) ->
        e.preventDefault()
        w.close()
        if type is 'person'
          editPersonParticipation 'Teilnahme korrigieren', participation, (data) ->
            changeData(data)
        else
          editTeamParticipation 'Teilnahme korrigieren', participation, (data) ->
            changeData(data)
      )
      up = $('<button/>').text('↑').on('click', (e) ->
        e.preventDefault()
        w.close()
        data = {
          rank: participation.rank - 1
          points: participation.points + 1
        }
        data.rank = 1 if data.rank < 1
        upDown(id, data)
      )
      down = $('<button/>').text('↓').on('click', (e) ->
        e.preventDefault()
        w.close()
        data = {
          rank: participation.rank + 1
          points: participation.points - 1
        }
        data.points = 0 if data.points < 0
        upDown(id, data)
      )
      destroy = $('<button/>').text('Löschen').on('click', (e) ->
        e.preventDefault()
        w.close()
        new ConfirmFssWindow 'Löschen?', 'Diesen Eintrag wirklich löschen?', ->
          Fss.ajaxReload('DELETE', "#{url_path}/#{id}", {})
      )
      cancel = $('<button/>').text('Abbrechen').on('click', (e) ->
        e.preventDefault()
        w.close()
      )
      w.add((new FssFormRow(change, up, down, destroy, cancel)).addClass('submit-row'))
      w.open()

  new SortTable({ selector: '.datatable-scores', direction: 'asc' })
