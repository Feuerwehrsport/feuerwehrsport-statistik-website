class @FssMap
  @styleLoaded: false
  @loaded: (callback) ->
    FssMap.styleLoaded = true
    callback()

  @lat: 51
  @lon: 13

  @loadStyle: (callback) ->
    return callback() if FssMap.styleLoaded

    $.getScript '/js/leaflet.js', () ->
      L.Icon.Default.imagePath = '/styling/images/'
      $.get '/css/leaflet.css', (css) ->
        $('<style type="text/css"></style>').html(css).appendTo("head")
        if $.browser.msie && parseInt($.browser.version, 10) < 8
          $.get '/css/leaflet.ie.css', (css) ->
            $('<style type="text/css"></style>').html(css).appendTo("head")
            FssMap.loaded(callback)
        else
          FssMap.loaded(callback)

  @getMap: (id, zoom=8, lat=FssMap.lat, lon=FssMap.lon) ->
    osmUrl = "http://b.tile.openstreetmap.de/tiles/osmde/{z}/{x}/{y}.png"
    osmAttrib = 'Map data © <a href="http://openstreetmap.org">openstreetmap</a>'
    osm = L.tileLayer(osmUrl, {attribution: osmAttrib})

    fireUrl = 'http://openfiremap.org/hytiles/{z}/{x}/{y}.png'
    fireAttrib = '<a href="http://openfiremap.org">openfiremap</a>'
    fire = L.tileLayer(fireUrl, {attribution: fireAttrib, minZoom: 11})
    return L.map id, 
      center: L.latLng(lat, lon)
      zoom: zoom
      scrollWheelZoom: false
      layers: [osm, fire]

  @redIcon: () -> 
    unless FssMap.RedIcon?
      FssMap.RedIcon = L.Icon.Default.extend(options: { iconUrl: '/styling/images/marker-icon-red.png' })
    new FssMap.RedIcon()
