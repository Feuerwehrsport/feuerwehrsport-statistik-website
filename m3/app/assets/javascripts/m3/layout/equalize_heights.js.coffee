equalizeHeights = ->
  genericId = 0;
  $('[data-equalize-height-container]').each ->
    container = $(this)
    id = container.attr('id')
    if !id
      id = 'generic-id-equalizeHeights-' + String(genericId++)
      container.attr 'id', id
    container.find('[data-equalize-height]').each ->
      $(this).data 'equalize-height', id + $(this).data('equalize-height')
      return
    return
  allElements = $('[data-equalize-height]')
  groups = allElements.map(->
    $(this).data 'equalize-height'
  ).toArray()
  groups = $.grep(groups, (item, index) ->
    index == $.inArray(item, groups)
  )
  i = 0
  while i < groups.length
    elements = allElements.filter(->
      $(this).data('equalize-height') == groups[i]
    )
    elements.height ''
    offsetsTop = $.makeArray(elements.map(->
      $(this).offset().top
    ))
    if offsetsTop.length > 1 && offsetsTop[0] == offsetsTop[1]
      heights = $.makeArray(elements.map(->
        $(this).height()
      ))
      maxHeight = Math.max.apply(null, heights)
      elements.each ->
        element = $(this)
        diff = element.outerHeight() - element.height()
        element.height maxHeight - diff
    i++

M3.ready(equalizeHeights)
M3.load(equalizeHeights)
$(window).resize(equalizeHeights)

M3.equalizeHeights = equalizeHeights