window.M3 = M3 = {}

M3.ready = (cb) ->
  if window.Turbolinks
    $(document).on('turbolinks:load', (ev) -> cb(ev, document))
  else
    $((ev) -> cb(ev, document))
    $(document).on('page:load', (ev) -> cb(ev, document))
  $(document).on('m3:page:ready', (ev, context) -> cb(ev, context || document))

M3.load = (cb) ->
  $(window).load(cb)
  $(document).on 'page:load', ->
    $(document).find('img').one('load', cb)
    cb()

M3.unload = (cb) ->
  $(document).on('page:before-change', cb)
