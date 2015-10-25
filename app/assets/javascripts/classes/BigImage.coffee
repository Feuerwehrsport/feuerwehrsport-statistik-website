class BigImage
  constructor: (@image) ->
    @image
      .attr('title', 'Klicken zum Vergrößern')
      .css('cursor', 'pointer')
      .click(@getBigImage)
  getBigImage: () =>
    newSrc = @image.attr('src').replace(/chart\//, 'chart/big/')
    @big = $('<img/>')
      .attr('src', newSrc)
      .css('display', 'none')
    @image.css('cursor', 'wait')

    os = @image.offset()
    left = os.left + @image.width()/2
    top = os.top + @image.height()/2

    @big.load () =>
      w = @big.get(0).width
      h = @big.get(0).height

      @image.css('cursor', 'pointer')
      @big
        .attr('title', 'Klicken zum Schließen')
        .css(
          position: 'absolute'
          top: os.top
          left: os.left
          width: @image.width()
          height: @image.height()
        ).fadeIn(100, () =>
          @big.animate(
            top: top - h/2
            left: left - w/2
            width: w
            height: h
          ).click( () =>
            @big.animate(
              top: os.top
              left: os.left
              width: @image.width()
              height: @image.height()
            , () =>
              @big.remove()
            )
          )
        )
    $('body').append(@big)