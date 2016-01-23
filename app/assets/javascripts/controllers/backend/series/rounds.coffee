editParticipation = (title, participation, success) ->
  Fss.getResources 'people', (people) ->
    options = []
    for person in people
      options.push
        value: person.id
        display: "#{person.last_name}, #{person.first_name} (#{person.translated_gender})"
    FssWindow.build(title)
    .add(new FssFormRowSelect('person_id', 'Richtige Person', participation.person_id, options))
    .add(new FssFormRowText('rank', 'Platz', participation.rank))
    .add(new FssFormRowText('points', 'Punkte', participation.points))
    .add(new FssFormRowText('time', 'Zeit', participation.time))
    .on('submit', success)
    .open()

$ () ->
  $('#edit-series-participations .series-participation').each () ->
    $(@).addClass("btn btn-default btn-xs")

  $('.add-person-participation').click () ->
    assessmentId = $(@).data('assessment-id')
    cupId = $(@).data('cup-id')
    editParticipation 'Teilnahme hinzufügen', {}, (data) ->
      data.assessment_id = assessmentId
      data.cup_id = cupId
      Fss.ajaxReload("POST", "series/participations", series_participation: data)

  $(document).on 'click', '#edit-series-participations .series-participation', () ->
    id = $(@).data('id')

    w = FssWindow.build("Serienteilnahme")
    change = $('<button/>').text('Ändern').on('click', (e) ->
      e.preventDefault()
      w.close()

      Fss.getResource 'series/participations', id, (participation) ->
        editParticipation 'Teilnahme korrigieren', participation, (data) ->
          Fss.ajaxReload("PUT", "series/participations/#{id}", series_participation: data)
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
    w.add((new FssFormRow(change, destroy, cancel)).addClass('submit-row'))
    w.open()

  new SortTable(selector: ".datatable-scores", direction: 'asc')

