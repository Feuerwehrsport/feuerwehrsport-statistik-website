#= require classes/Fss
#= require classes/SortTable

Fss.ready 'team', ->
  new SortTable({ selector: '.datatable-team-members', direction: 'asc' })
  new SortTable({ selector: '.datatable-team-competitions' })
  new SortTable({ selector: '.datatable-group-assessments', noSorting: [5, 6] })
  new SortTable({ selector: '.datatable-group-disciplines' })

  FssMap.load('team')

  # map position is still edited here (FssMap); the dialog "Fehler melden" links to it
  $('#add-geo-position').click ->
    FssMap.load('team', true)
  # the link is loaded later into the dialog, so a delegated handler is needed
  $(document).on 'click', '.start-team-map-edit', ->
    FssMap.load('team', true)

  if $('#teams-map').length > 0
    elem = $('#teams-map')
    map = FssMap.getMap('teams-map')
    markers = for marker in elem.data('map').markers
      L.circle(marker.latlon, marker.count * 20, { icon: FssMap.defaultIcon() }).bindPopup(marker.popup).addTo(map)
    setTimeout( ->
      map.fitBounds([[50.4, 5.9], [54.5, 16.8]])
    , 300)
