$ () ->
  new SortTable(selector: ".datatable-places", direction: 'asc')
  new SortTable(selector: ".datatable-place-competitons", direction: 'desc')

  if $('#places-map').length > 0
    elem = $('#places-map')
    FssMap.loadStyle () ->
      map = FssMap.getMap('places-map')
      markers = for marker in elem.data('map').markers
        L.circle(marker.latlon, marker.count*200, icon: FssMap.defaultIcon()).bindPopup(marker.popup).addTo(map)
      setTimeout( ->
        map.fitBounds(L.featureGroup(markers).getBounds(), padding: [20, 20])
      , 300)