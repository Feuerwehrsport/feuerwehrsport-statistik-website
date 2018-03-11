marker = null
mapLoaded = false
@.loadMap = (draggableMarker = false, position = null) ->
  return if $('#team-map').length is 0

  elem = $('#team-map').hide()
  red = elem.data('map').red
  if red or draggableMarker
    elem.show()
    w = new WaitFssWindow() if draggableMarker
    FssMap.loadStyle ->
      w.close() if draggableMarker
      
      latlon = [FssMap.lat, FssMap.lon]
      latlon = red.latlon if red
      latlon = position if position

      map = FssMap.getMap('team-map', latlon) unless mapLoaded
      mapLoaded = true

      marker = L.marker(latlon, { icon: FssMap.redIcon() }).addTo(map) if marker is null
      marker.bindPopup(red.popup) if red
      marker.dragging.enable() if draggableMarker

  if draggableMarker
    actions = $('.team-map-actions')
    actions.children().remove()
    $('<div/>').addClass('btn btn-primary').text('Speichern').appendTo(actions).click ->
      Fss.checkLogin ->
        Fss.ajaxReload 'PUT', "teams/#{elem.data('team-id')}", {
          team: {
            latitude: marker.getLatLng().lat
            longitude: marker.getLatLng().lng
          }
          log_action: 'update-team:geo-position'
        }
