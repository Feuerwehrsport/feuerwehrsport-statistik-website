M3.ready ->
  window.CKEDITOR_BASEPATH = '/ckeditor/'
  if $('textarea.ckeditor-area').length > 0
    $.getScript '/ckeditor/ckeditor.js', ->
      $('textarea.ckeditor-area').each ->
        CKEDITOR.replace($(@).attr('id'))
