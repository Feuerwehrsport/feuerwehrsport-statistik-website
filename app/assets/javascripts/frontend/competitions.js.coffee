#= require classes/Fss
#= require classes/SortTable

Fss.ready 'competition', ->
  new SortTable({ selector: '.datatable-competitons', direction: 'desc' })
  new SortTable({ selector: '.datatable.scores-group', direction: 'asc', sortCol: 1 })
  new SortTable({ selector: '.datatable.scores-zk', direction: 'asc', sortCol: 4 })
  new SortTable({ selector: '.datatable.scores-single', direction: 'asc', sortCol: 3 })


  if $('#competition-map').length > 0
    elem = $('#competition-map')
    red = elem.data('map').red
    map = FssMap.getMap('competition-map')
    markers = elem.data('map').markers or []
    markers = for marker in markers
      L.marker(marker.latlon, { icon: FssMap.defaultIcon() }).bindPopup(marker.popup).addTo(map)
    markers.push(L.marker(red.latlon, { icon: FssMap.redIcon() }).bindPopup(red.popup).addTo(map))
    setTimeout( ->
      map.fitBounds(L.featureGroup(markers).getBounds(), { padding: [20, 20] })
    , 300)
