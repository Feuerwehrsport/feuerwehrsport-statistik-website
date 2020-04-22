marker = null
map = null

Fss.ready ->
  marker = null
  map = null

class @FssMap
  @lat: 51
  @lon: 13

  @getMap: (id, latLon=[FssMap.lat,FssMap.lon], zoom=8) ->
    osmUrl = "https://b.tile.openstreetmap.de/tiles/osmde/{z}/{x}/{y}.png"
    osmAttrib = 'Map data © <a href="http://openstreetmap.org">openstreetmap</a>'
    osm = L.tileLayer(osmUrl, {attribution: osmAttrib})

    return L.map id,
      center: latLon
      zoom: zoom
      scrollWheelZoom: false
      layers: [osm]

  @defaultIcon: () ->
    unless FssMap.DefaultIcon?
      FssMap.DefaultIcon = L.Icon.Default.extend(options:
        iconUrl: 'marker-icon.png'
        shadowUrl: 'marker-shadow.png'
      )
    new FssMap.DefaultIcon()

  @redIcon: () ->
    unless FssMap.RedIcon?
      FssMap.RedIcon = L.Icon.Default.extend(options:
        iconUrl: 'marker-icon-red.png'
        shadowUrl: 'marker-shadow.png'
      )
    new FssMap.RedIcon()


  @load: (type, draggableMarker = false, position = null) ->
    return if $("##{type}-map").length is 0

    if marker?
      marker.remove()
      marker = null

    elem = $("##{type}-map").hide()
    red = elem.data('map').red
    if red or draggableMarker
      elem.show()

      latlon = [FssMap.lat, FssMap.lon]
      latlon = red.latlon if red
      latlon = position if position

      if map?
        map.panTo(latlon)
      else
        map = FssMap.getMap("#{type}-map", latlon)

      marker = L.marker(latlon, { icon: FssMap.redIcon() }).addTo(map) if marker is null
      marker.bindPopup(red.popup) if red
      marker.dragging.enable() if draggableMarker

    if draggableMarker
      actions = $(".#{type}-map-actions")
      actions.children().remove()
      $('<div/>').addClass('btn btn-primary').text('Speichern').appendTo(actions).click ->
        Fss.checkLogin ->
          options = { log_action: "update-#{type}:geo-position" }
          options[type] = {
            latitude: marker.getLatLng().lat
            longitude: marker.getLatLng().lng
          }
          Fss.ajaxReload 'PUT', "#{type}s/#{elem.data("#{type}-id")}", options