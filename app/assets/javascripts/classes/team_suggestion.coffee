class TeamSuggestion
  constructor: ->
    @lastValue = ''

    $(document).on 'keyup', '#team_suggestion', =>
      newValue = $('#team_suggestion').val()
      if @lastValue isnt newValue and newValue isnt ''
        @lastValue = newValue
        @updateSuggestions()

        $('#registrations_team_name').val(newValue)
        $('#registrations_team_shortcut').val(newValue.replace(/^\s*FF\s*/, '').replace(/^\s*Team\s*/, ''))

    $(document).on 'modal.ready', ->
      $('#team_suggestion').trigger('keyup')

    $(document).on 'change', '#registrations_team_name, #registrations_team_shortcut', ->
      $('#registrations_team_team_id').val('')

  updateSuggestions: =>
    table = $('.suggestions-entries table')
    params = { name: @lastValue }

    $.post '/api/suggestions/teams', params, (result) =>
      table.children().remove()
      for team in result.teams
        table.append(@buildTr(team))

  buildTr: (entry) ->
    setValues = (team) ->
      $('#registrations_team_name').val(entry.name)
      $('#registrations_team_shortcut').val(entry.shortcut)
      $('#registrations_team_team_id').val(entry.id)

    $('<tr/>')
    .append($('<td/>').text(entry.name).addClass('name'))
    .append($('<td/>').text(entry.shortcut).addClass('shortcut'))
    .click ->
      setValues()

M3.ready ->
  new TeamSuggestion
