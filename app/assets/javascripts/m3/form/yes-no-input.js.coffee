M3.ready ->
  $('.radio_buttons.optional.form-group').each ->
    group = $(@)
    if $('.yes-no-input', group).length > 0
      $('<input type="hidden"/>').attr('name', $('.yes-no-input', group).attr('name')).attr('value', '').insertBefore(group)
      reset = $('<a/>').text(I18n.reset_link).appendTo(group.find('.col-sm-9')).click ->
        $('.yes-no-input', group).removeProp('checked')
        showResetLink()

      showResetLink = ->
        if $('.yes-no-input:checked', group).val()?
          reset.show()
        else
          reset.hide()

      $('.yes-no-input', group).change showResetLink
      showResetLink()

