$ () ->
  $('input.person-assessment').each () ->
    context = $(@)
    formGroup = context.closest('.form-group').addClass("single-competitor-order")
    checkbox = context.closest('td').find("input[type=checkbox]")
    checkbox.closest('.form-group').addClass("person-assessment")    
    
    checkbox.change(() ->
      opacity = if checkbox.is(':checked') then 1 else 0.3
      formGroup.css(opacity: opacity)
    ).change()