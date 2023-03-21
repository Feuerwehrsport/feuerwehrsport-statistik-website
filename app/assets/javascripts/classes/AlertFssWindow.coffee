#= require classes/FssWindow
#= require classes/FssFormRow

class @AlertFssWindow extends FssWindow
  constructor: (title, message, callback = false) ->
    super(title)
    @add(new FssFormRow($('<p/>').text(message)))
    @add(new FssFormRow($('<button/>').addClass('btn btn-primary btn-xs').text('OK').on('click', (e) =>
      e.preventDefault()
      @close()
      callback() if callback
    )))
    @open()
