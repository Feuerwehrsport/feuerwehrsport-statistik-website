#= require froala_editor.min.js
#= require plugins/align.min.js
#= require plugins/code_beautifier.min.js
#= require plugins/code_view.min.js
#= require plugins/colors.min.js
#= require plugins/entities.min.js
#= require plugins/fullscreen.min.js
#= require plugins/image.min.js
#= require plugins/line_breaker.min.js
#= require plugins/link.min.js
#= require plugins/lists.min.js
#= require plugins/paragraph_format.min.js
#= require plugins/table.min.js
#= require plugins/url.min.js
#= require languages/de.js


$ ->
  buttons = ['fullscreen', 'bold', 'italic', 'underline', 'strikeThrough', '|', 'color', '|', 'paragraphFormat', 'align', 'formatOL', 'formatUL', 'outdent', 'indent', 'insertHR', '-', 'insertLink', 'insertImage', 'insertTable', 'undo', 'redo', 'clearFormatting', 'html']
  $('.froala-text-area').froalaEditor(
    language: 'de'
    imageUpload: false
    imagePaste: false
    imageInsertButtons: ['imageBack', '|', 'imageByURL']
    toolbarButtons: buttons
    toolbarButtonsMD: buttons
    toolbarButtonsSM: buttons
    toolbarButtonsXS: buttons
  )
