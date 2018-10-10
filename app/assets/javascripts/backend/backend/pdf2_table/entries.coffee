reduceCountdown = ->
  current = parseInt($('span.reload-counter').text(), 10)
  if current < 2
    location.reload()
  else
    $('span.reload-counter').text(current - 1)

Fss.ready 'pdf2_table/entr', ->
  return if $('span.reload-counter').length is 0
  setInterval(reduceCountdown, 1000)
