class PersonSuggestion
  constructor: () ->
    @lastValue = ""

    $(document).on "keyup", '#person_suggestion', () =>
      newValue = $('#person_suggestion').val()
      if @lastValue isnt newValue && newValue isnt ""
        @lastValue = newValue
        @updateSuggestions()

        for name, i in newValue.split(" ")
          if i is 0
            $('#comp_reg_person_first_name').val(name)
          else
            $('#comp_reg_person_last_name').val(name)
    $(document).on 'modal.ready', () ->
      $('#person_suggestion').trigger('keyup')

    $(document).on "change", '#comp_reg_person_first_name, #comp_reg_person_last_name', () ->
      $('#comp_reg_person_person_id').val("")

  updateSuggestions: () =>
    table = $('.suggestions-entries table')
    params =
      name: @lastValue
      team_name: $('#person_suggestion').data('team-name')

    suggestion_gender = $('#comp_reg_person_gender').val()
    params.gender = suggestion_gender if suggestion_gender

    $.post "/api/suggestions/people", params, (result) =>
      table.children().remove()
      for person in result.people
        table.append(@buildTr(person))

  buildTr: (entry) ->
    $('<tr/>')
    .append($('<td/>').text(entry.first_name).addClass("first_name"))
    .append($('<td/>').text(entry.last_name).addClass("last_name"))
    .append($('<td/>').text(entry.teams.join(", ")).addClass("team"))
    .click () ->
      $('#comp_reg_person_first_name').val(entry.first_name)
      $('#comp_reg_person_last_name').val(entry.last_name)
      $('#comp_reg_person_gender').val(entry.gender)
      $('#comp_reg_person_person_id').val(entry.id)
      $('#comp_reg_person_team_name').val(entry.teams[0])

$ () ->
  new PersonSuggestion