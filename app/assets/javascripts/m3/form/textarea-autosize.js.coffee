#= require jquery.autosize

M3.ready ->
  $('textarea').not('.wysiwyg').autosize()
  $( document ).on( 'shown.bs.modal', 'div.modal', ->
    $('textarea').not('.wysiwyg').trigger('autosize.resize')
  )
