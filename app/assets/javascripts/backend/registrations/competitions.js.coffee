#= require classes/Fss
#= require classes/person_suggestion
#= require lib/edit_participations

Fss.ready 'backend/registrations/competition', ->
  originalUrl = $('#slug-url').text()
  $('#comp_reg_competition_slug').on('change keyup paste', ->
    slug = $(this).val()
    $('#slug-url').text(originalUrl.replace(/\[SLUG\]/, slug))
  ).change()