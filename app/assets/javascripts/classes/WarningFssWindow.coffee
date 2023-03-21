#= require classes/FssWindow

class @WarningFssWindow extends FssWindow
  constructor: (title) ->
    super(title)
    @add(new FssFormRow($('<div/>').addClass('warning-fss-window')))
    @add(new FssFormRow($('<button/>').addClass('btn btn-primary btn-xs').text('OK').on('click', (e) =>
      e.preventDefault()
      @close()
    )))
    @open()
