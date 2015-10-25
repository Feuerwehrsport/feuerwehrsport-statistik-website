#= require classes/EventHandler
#= require classes/FssFormRow

class @FssWindow extends EventHandler
  @build: (title) ->
    new FssWindow(title)

  constructor: (@title) ->
    super
    @rows = []
    @rendered = false
    @on('pre-submit', () =>
      @close()
      @fire('submit', @data())
    )

  render: () =>
    @container = $('<div/>').addClass('fss-window').append(
      $('<div/>').addClass('fss-window-title').text(@title)
    )
    @darkroom = $('<div/>').addClass('darkroom')

    if @handlers['submit']? and @handlers['submit'].length > 0
      submit = $('<button/>').text('OK').on('click', (e) => 
        e.preventDefault()
        @fire('pre-submit')
      )
      cancel = $('<button/>').text('Abbrechen').on('click', (e) => 
        e.preventDefault()
        @close()
        @fire('cancel')
      )
      @add((new FssFormRow(submit, cancel)).addClass('submit-row'))

    form = $('<form/>').on('submit', (e) => 
      e.preventDefault()
      @fire('pre-submit')
    )
    form.append(row.content()) for row in @rows
    @container.append(form)
    @rendered = true
    @

  add: (row) =>
    @rows.push(row)
    row.fire('after-add', @)
    @

  open: () =>
    @render() unless @rendered

    $('body').append(@darkroom).append(@container)

    left = (window.innerWidth/2 - parseInt(@container.css('width'))/2)
    top = (window.innerHeight/2 - parseInt(@container.css('height'))/2)

    left = 10 if left < 10
    top = 10  if top < 10

    top += parseInt($(document).scrollTop())
    @container.css('top', top).css('left', left)

    for row in @rows
      break if row.focus() 
    @fire('after-open')
    @

  close: () =>
    @container.remove()
    @darkroom.remove()
    @

  data: () =>
    data = {}
    for row in @rows
      data = row.appendData(data) 
    data