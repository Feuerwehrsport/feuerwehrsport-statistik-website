class @EventHandler
  constructor: ->
    @handlers = {}

  on: (type, callback) ->
    @handlers[type] ||= []
    @handlers[type].push(callback)
    this

  off: (type, callback) ->
    @handlers[type] ||= []
    for method, i in @handlers[type]
      if method is callback
        @handlers.splice(i, 1)
        return this
    this

  fire: (type, data) ->
    @handlers[type] ||= []
    method.call(this, data) for method in @handlers[type]
    this
