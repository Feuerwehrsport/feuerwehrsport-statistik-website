handlers = []
resetHandler = ->
  $('.assessment-participation').each ->
    context = $(this)
    checkbox = context.find('input[type=checkbox]')
    if $.inArray(checkbox[0], handlers) < 0
      checkbox.change(->
        if checkbox.is(':checked')
          context.find('.edit-assesment-type').css({ opacity: 1 })
          context.find('.edit-assesment-type').find('select, input').prop('disabled', false)
        else
          context.find('.edit-assesment-type').css({ opacity: 0.3 })
          context.find('.edit-assesment-type').find('select, input').prop('disabled', true)
      ).change()
      handlers.push(checkbox[0])
      context.find('select').change( ->
        if $(this).val() is 'group_competitor'
          context.find('.group-competitor-order').show()
          context.find('.single-competitor-order').hide()
          context.find('.competitor-order').hide()
        else if $(this).val() is 'single_competitor'
          context.find('.single-competitor-order').show()
          context.find('.group-competitor-order').hide()
          context.find('.competitor-order').hide()
        else if $(this).val() is 'competitor'
          context.find('.competitor-order').show()
          context.find('.group-competitor-order').hide()
          context.find('.single-competitor-order').hide()
        else
          context.find('.single-competitor-order').hide()
          context.find('.group-competitor-order').hide()
      ).change()

M3.ready ->
  $(document).on 'modal.ready hidden.bs.modal', ->
    resetHandler()
  resetHandler()
