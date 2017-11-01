#= require classes/Fss

Fss.ready 'wettkampf_manager', ->
  $('.version-select').click (ev) ->
    ev.preventDefault()
    $this = $(@)

    $('.version-select').removeClass('active')
    $('div[data-version]').addClass("hide")
    
    $this.addClass('active')
    $("div[data-version='#{$this.data('version')}']").removeClass('hide')
