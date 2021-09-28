ajaxRequest = {}
replacePlaceholder = (url, placeholder) ->
  path = url.split('?', 2)[0]
  ajaxRequest[path].abort() if ajaxRequest[path]

  placeholder.children().css(opacity: 0.5)
  ajaxRequest[path] = $.ajax
    url: url
    cache: false
    success: (content) ->
      html = $("<div>#{content}</div>").find('div.section > div.container').children()
      placeholder.children().remove()
      placeholder.append(html)
      placeholder.find('.is-sortable a, .pagination a').each ->
        $(@).click (ev) ->
          ev.preventDefault()
          url = $(@).attr('href')
          path = url.split('?', 2)
          url = path[0]
          url += '.js' unless url.match(/\.js$/)
          url += "?#{path[1]}" if path.length > 1

          replacePlaceholder(url, placeholder)

M3.ready ->
  $.urlParam = (name) ->
    results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href)
    results[1] if results

  $('div[data-remote-index-table]').each ->
    placeholder = $(@)
    url = placeholder.data('remote-index-table')
    placeholder.removeData('remote-index-table')

    url = if url.match(/\?/) then url.replace(/\?/, '.js?') else "#{url}.js"
    replacePlaceholder(url, placeholder)


Modernizr.addTest('ipad', ->
  !!navigator.userAgent.match(/iPad/i)
)

Modernizr.addTest('iphone', ->
  !!navigator.userAgent.match(/iPhone/i)
)

Modernizr.addTest('ipod', ->
  !!navigator.userAgent.match(/iPod/i)
)

Modernizr.addTest('appleios', ->
  (Modernizr.ipad || Modernizr.ipod || Modernizr.iphone)
)