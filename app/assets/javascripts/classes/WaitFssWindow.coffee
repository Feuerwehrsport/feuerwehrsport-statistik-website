#= require classes/FssWindow

class @WaitFssWindow extends FssWindow
  constructor: () ->
    super("Bitte warten")
    @add(new FssFormRow($('<div/>').addClass("wait-fss-window")))
    @open()