class PersonSuggestion
  constructor: ->
    @lastValue = ''

    $(document).on 'keyup', '#person_suggestion', =>
      newValue = $('#person_suggestion').val()
      if @lastValue isnt newValue and newValue isnt ''
        @lastValue = newValue
        @updateSuggestions()

        for name, i in newValue.split(' ')
          if i is 0
            $('#registrations_person_first_name').val(name)
          else
            $('#registrations_person_last_name').val(name)
    $(document).on 'modal.ready', ->
      $('#person_suggestion').trigger('keyup')

    $(document).on 'change', '#registrations_person_first_name, #registrations_person_last_name', ->
      $('#registrations_person_person_id').val('')

  updateSuggestions: =>
    table = $('.suggestions-entries table')
    params = {
      name: @lastValue
      team_name: $('#person_suggestion').data('team-name')
    }
    suggestion_gender = $('#registrations_person_gender').val()
    params.gender = suggestion_gender if suggestion_gender

    $.post '/api/suggestions/people', params, (result) =>
      table.children().remove()
      for person in result.people
        table.append(@buildTr(person))

  buildTr: (entry) ->
    setValues = (team) ->
      $('#registrations_person_first_name').val(entry.first_name)
      $('#registrations_person_last_name').val(entry.last_name)
      $('#registrations_person_gender').val(entry.gender)
      $('#registrations_person_person_id').val(entry.id)
      $('#registrations_person_team_name').val(team or entry.teams[0])

    teamsTd = $('<td/>')
    $.each(entry.teams, (index, team) ->
      $('<span/>').appendTo(teamsTd).text(team).click ->
        setValues(team)
        false
      teamsTd.append(', ') if index < entry.teams.length - 1
    )
    $('<tr/>')
    .append($('<td/>').text(entry.first_name).addClass('first_name'))
    .append($('<td/>').text(entry.last_name).addClass('last_name'))
    .append(teamsTd.addClass('team'))
    .click ->
      setValues()

M3.ready ->
  new PersonSuggestion
