
M3.ready ->
  $('.legend-input').each ->
    legend = $(@)
    input = legend.find('input[type=checkbox]')
    fieldset = legend.closest('fieldset')
    content = fieldset.children('.fieldset-content')

    if !input[0].checked
      content.hide()

    input.change ->
      if @checked
        content.slideDown('fast')
      else
        content.slideUp('fast')
