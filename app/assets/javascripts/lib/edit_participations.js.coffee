handlers = []
resetHandler = () ->
  console.log(this)
  $('.assessment-participation').each () ->
    context = $(this)
    checkbox = context.find("input[type=checkbox]")
    if $.inArray(checkbox[0], handlers) < 0
      checkbox.change(() ->
        opacity = if checkbox.is(':checked') then 1 else 0.3
        context.find('.edit-assesment-type').css(opacity: opacity)
      ).change()
      handlers.push(checkbox[0])
      context.find('select').change( () ->
        if $(this).val() is 'group_competitor'
          context.find('.group-competitor-order').show()
          context.find('.single-competitor-order').hide()
        else if $(this).val() is 'single_competitor'
          context.find('.single-competitor-order').show()
          context.find('.group-competitor-order').hide()
        else
          context.find('.single-competitor-order').hide()
          context.find('.group-competitor-order').hide()
      ).change()



$ () ->
  $(document).on 'modal.ready hidden.bs.modal', ->
    resetHandler()
  resetHandler()