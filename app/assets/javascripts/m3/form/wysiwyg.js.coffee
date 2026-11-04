M3.ready ->
  window.CKEDITOR_BASEPATH = '/ckeditor/'
  if $('textarea.ckeditor-area').length > 0
    $.getScript '/ckeditor/ckeditor.js', ->
      $('textarea.ckeditor-area').each ->
        CKEDITOR.replace($(@).attr('id'))


  try
    if window.opener?
      window.opener.editor_func_num = editor_func_num = $.urlParam("CKEditorFuncNum") || window.opener.editor_func_num
      window.opener.editor_name = editor_name = $.urlParam("CKEditor") || window.opener.editor_name
      if editor_func_num? && editor_name?
        opener_ckeditor = window.opener.CKEDITOR
        if opener_ckeditor? && editor_func_num?
          $('a[data-m3-asset-url]').click ->
            url = $(@).data('m3-asset-url')
            name = $(@).data('m3-asset-name')
            opener_ckeditor.tools.callFunction editor_func_num, url, ->
              dialog = @.getDialog()
              if dialog.getName() == 'image'
                element = dialog.getContentElement('info', 'txtAlt')
                element.setValue(name) if element
            window.close()
  catch err
    console.error(err) if console