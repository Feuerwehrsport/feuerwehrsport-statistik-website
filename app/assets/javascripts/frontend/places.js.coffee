#= require classes/Fss
#= require classes/SortTable

Fss.ready 'place', ->
  new SortTable({ selector: '.datatable-places', direction: 'asc' })
  new SortTable({ selector: '.datatable-place-competitons', direction: 'desc' })

  if $('#places-map').length > 0
    elem = $('#places-map')
    map = FssMap.getMap('places-map')
    markers = for marker in elem.data('map').markers
      L.circle(marker.latlon, marker.count * 200, { icon: FssMap.defaultIcon() }).bindPopup(marker.popup).addTo(map)
    setTimeout( ->
      map.fitBounds([[49.4, 5.9], [54.5, 16.8]])
    , 300)

  FssMap.load('place')

  $('#change-geo-position').click ->
    FssMap.load('place', true)
