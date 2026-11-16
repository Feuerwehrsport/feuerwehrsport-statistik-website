# overview maps with many markers (teams, places, competitions); editing a position: stimulus geo-position
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
