#= require classes/EventHandler
#= require classes/FssFormRow

class @FssWindow extends EventHandler
  @build: (title) ->
    new FssWindow(title)

  constructor: (@title) ->
    super()
    @rows = []
    @rendered = false
    @on('after-open', =>
      window.fssWindows = [] unless window.fssWindows?
      window.fssWindows.push(this)
    )
    @on('after-close', =>
      window.fssWindows.splice($.inArray(this, window.fssWindows), 1)
    )
    @on('pre-submit', =>
      @close()
      @fire('submit', @data())
    )

  render: =>
    title = $('<div/>').addClass('fss-window-title').append(@title)
    if Fss.loginStatus
      title.append($('<div/>').addClass("fss-window-sign-out login-#{Fss.loginUser.type}")
        .append($('<div/>').addClass('glyphicon glyphicon-user'))
        .append(Fss.loginUser.name)
        .attr('title', "Ausloggen (#{Fss.loginUser.type}: #{Fss.loginUser.name})")
        .click( ->
          fssWindow.closefor(fssWindow) in window.fssWindows
          Fss.logoutWindow()
        )
      )

    @container = $('<div/>').addClass('fss-window').append(title)
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
    this

  add: (row) =>
    @rows.push(row)
    row.fire('after-add', this)
    this

  open: =>
    @render() unless @rendered

    $('body').append(@darkroom).append(@container)

    left = (window.innerWidth / 2 - parseInt(@container.css('width')) / 2)
    top = (window.innerHeight / 2 - parseInt(@container.css('height')) / 2)

    left = 10 if left < 10
    top = 10  if top < 10

    top += parseInt($(document).scrollTop())
    @container.css('top', top).css('left', left)

    for row in @rows
      break if row.focus
    @fire('after-open')
    this

  hide: =>
    @container.hide()
    @darkroom.hide()

  unhide: =>
    @container.show()
    @darkroom.show()

  close: =>
    @container.remove()
    @darkroom.remove()
    @fire('after-close')
    this

  data: =>
    data = {}
    for row in @rows
      data = row.appendData(data)
    data
