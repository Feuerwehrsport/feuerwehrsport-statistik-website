$ ->
  window.CKEDITOR_BASEPATH = '/vendor/ckeditor/';
  $.getScript '/vendor/ckeditor/ckeditor.js', ->
    $('.ckeditor-area textarea').each ->

      CKEDITOR.replace($(@).attr('id'))