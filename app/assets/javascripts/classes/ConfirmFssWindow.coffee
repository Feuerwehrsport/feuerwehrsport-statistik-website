#= require classes/FssWindow
#= require classes/FssFormRow

class @ConfirmFssWindow extends FssWindow
  constructor: (title, message, submit, cancel = false) ->
    super(title)
    @add(new FssFormRow($('<p/>').text(message)))
    @on('submit', submit)
    @on('cancel', cancel) if cancel
    @open()
