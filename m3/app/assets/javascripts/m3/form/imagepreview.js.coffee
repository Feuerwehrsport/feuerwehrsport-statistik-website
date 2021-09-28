$.fn.imagePreviewInput = ->
  $(this).each ->
    imagepreview = $(this)
    image = imagepreview.find('img.imagepreview-image')

    editInput = imagepreview.find('input[type=file]')
    editButton = imagepreview.find('.imagepreview-actions-edit')
    editInputWrapper = imagepreview.find('.imagepreview-input-wrapper')

    removeCheckBox = imagepreview.find('.imagepreview-remove')
    removeButton = imagepreview.find('.imagepreview-actions-remove')
    removeHint = imagepreview.find('.imagepreview-remove-hint')

    resetButton = imagepreview.find('.imagepreview-actions-reset')

    editInputWrapper.hide() if removeCheckBox.length > 0
    removeCheckBox.closest('.checkbox').hide()
    removeHint.hide()
    resetButton.hide()

    edit = ->
      imagepreview.addClass('is-edited')
      editButton.addClass('active').blur()
      editInputWrapper.css(display: 'block')
      resetButton.show()

    unedit = ->
      imagepreview.removeClass('is-edited')
      editButton.removeClass('active').blur()
      editInputWrapper.hide()
      editInput.val('')

    remove = ->
      imagepreview.addClass('is-removed')
      removeButton.addClass('active').blur()
      removeHint.show()
      removeCheckBox.prop('checked', true)
      resetButton.show()

    unremove = ->
      imagepreview.removeClass('is-removed')
      removeHint.hide()
      removeButton.removeClass('active').blur()
      removeCheckBox.prop('checked', false)

    editButton.click ->
      unremove()
      edit()
    
    removeButton.click ->
      unedit()
      remove()

    resetButton.click ->
      unedit()
      unremove()
      resetButton.hide()
  
  this

M3.ready ->
  $('div.imagepreview').imagePreviewInput()