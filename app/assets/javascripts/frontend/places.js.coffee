#= require classes/Fss
#= require classes/SortTable

marker = null
mapLoaded = false
loadMap = (draggableMarker=false) ->
  return if $('#place-map').length is 0

  elem = $('#place-map').hide()
  red = elem.data('map').red
  if red || draggableMarker
    elem.show()
    w = new WaitFssWindow() if draggableMarker
    FssMap.loadStyle () ->
      w.close() if draggableMarker
      
      latlon = [FssMap.lat, FssMap.lon]
      latlon = red.latlon if red

      map = FssMap.getMap('place-map', latlon) unless mapLoaded
      mapLoaded = true

      marker = L.marker(latlon, icon: FssMap.redIcon()).addTo(map) if marker is null
      marker.bindPopup(red.popup) if red
      marker.dragging.enable() if draggableMarker

  if draggableMarker
    actions = $('.place-map-actions')
    actions.children().remove()
    $('<div/>').addClass('btn btn-primary').text("Speichern").appendTo(actions).click () ->
      Fss.checkLogin () ->
        Fss.ajaxReload 'PUT', "places/#{elem.data('place-id')}", 
          place:
            latitude: marker.getLatLng().lat
            longitude: marker.getLatLng().lng
          log_action: "update-geo-position"

Fss.ready 'place', ->
  new SortTable(selector: ".datatable-places", direction: 'asc')
  new SortTable(selector: ".datatable-place-competitons", direction: 'desc')

  if $('#places-map').length > 0
    elem = $('#places-map')
    FssMap.loadStyle () ->
      map = FssMap.getMap('places-map')
      markers = for marker in elem.data('map').markers
        L.circle(marker.latlon, marker.count*200, icon: FssMap.defaultIcon()).bindPopup(marker.popup).addTo(map)
      setTimeout( ->
        map.fitBounds([[49.4, 5.9],[54.5, 16.8]])
      , 300)

  loadMap()

  $('#change-geo-position').click () ->
    loadMap(true)
