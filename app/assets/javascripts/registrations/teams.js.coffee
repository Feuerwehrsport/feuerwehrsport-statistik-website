#= require classes/Fss
#= require classes/person_suggestion
#= require lib/edit_participations
#= require lib/jquery.sortable

updateOrder = ->
  i = 0
  $('.registration-form').each ->
    i++
    form = $(this)
    params = {
      authenticity_token: form.find('input[name=authenticity_token]').val()
      _method: 'patch'
      registrations_person: {
        registration_order: i
      }
    }
    $.post(form.attr('action'), params)

bindSortedTable = ->
  $('.people-sortable-table tbody').sortable({
    forcePlaceholderSize: true
    items: 'tr'
    placeholder: $('.people-sortable-table tr td.placeholder').parent().remove().removeClass('hide')
  }).on('sortupdate', updateOrder)

Fss.ready /^\/registrations\/competitions\/\d+\/teams\/\d+$/, ->
  bindSortedTable()
