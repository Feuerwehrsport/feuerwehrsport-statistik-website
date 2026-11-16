#= require classes/Fss
#= require classes/SortTable

Fss.ready 'team', ->
  new SortTable({ selector: '.datatable-team-members', direction: 'asc' })
  new SortTable({ selector: '.datatable-team-competitions' })
  new SortTable({ selector: '.datatable-group-assessments', noSorting: [5, 6] })
  new SortTable({ selector: '.datatable-group-disciplines' })

  if $('#teams-map').length > 0
    elem = $('#teams-map')
    map = FssMap.getMap('teams-map')
    markers = for marker in elem.data('map').markers
      L.circle(marker.latlon, marker.count * 20, { icon: FssMap.defaultIcon() }).bindPopup(marker.popup).addTo(map)
    setTimeout( ->
      map.fitBounds([[50.4, 5.9], [54.5, 16.8]])
    , 300)
