# runs page specific code after the page is ready (path: part of the url or regexp)
class @Fss
  @ready: (path, callback) ->
    M3.ready ->
      if typeof(path) is 'string' and window.location.pathname.indexOf("/#{path}") isnt -1
        callback()
      else if path instanceof RegExp and path.test(window.location.pathname)
        callback()
