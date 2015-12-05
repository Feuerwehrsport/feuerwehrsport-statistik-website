$ () ->
  new SortTable(selector: ".datatable-competitons", direction: 'desc')
  new SortTable(selector: ".datatable.scores-group", direction: 'desc', sortCol: 1)
  new SortTable(selector: ".datatable.scores-zk", direction: 'desc', sortCol: 4)
  new SortTable(selector: ".datatable.scores-single", direction: 'desc', sortCol: 3)


  if $('#competition-map').length > 0
    elem = $('#competition-map')
    FssMap.loadStyle () ->
      red = elem.data('map').red
      map = FssMap.getMap('competition-map')
      markers = for marker in elem.data('map').markers
        L.marker(marker.latlon, icon: FssMap.defaultIcon()).bindPopup(marker.popup).addTo(map)
      markers.push(L.marker(red.latlon, icon: FssMap.redIcon()).bindPopup(red.popup).addTo(map))
      setTimeout( ->
        map.fitBounds(L.featureGroup(markers).getBounds(), padding: [20, 20])
      , 300)