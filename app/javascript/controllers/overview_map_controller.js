import { Controller } from "@hotwired/stimulus"

const TILES = "https://b.tile.openstreetmap.de/tiles/osmde/{z}/{x}/{y}.png"
const ATTRIBUTION = 'Map data © <a href="http://openstreetmap.org">openstreetmap</a>'

// overview map with many entries (Leaflet, global L). The data comes from MapHelper#map (data-map).
// circle: radius factor per entry ("count"), otherwise markers; bounds: fixed view, otherwise fit all markers
export default class extends Controller {
  static values = { circle: Number, bounds: Array }

  connect() {
    const data = JSON.parse(this.element.dataset.map || "{}")
    this.map = L.map(this.element, { center: [51, 13], zoom: 8, scrollWheelZoom: false,
                                     layers: [L.tileLayer(TILES, { attribution: ATTRIBUTION })] })
    const layers = (data.markers || []).map((marker) => this.layer(marker))
    if (data.red) layers.push(L.marker(data.red.latlon, { icon: this.icon("marker-icon-red.png") }).bindPopup(data.red.popup))
    layers.forEach((layer) => layer.addTo(this.map))

    // the map needs its final size before fitting; no animation, the page may be left meanwhile (Turbo)
    this.fitTimeout = setTimeout(() => {
      if (this.boundsValue.length > 0) {
        this.map?.fitBounds(this.boundsValue, { animate: false })
      } else if (layers.length > 0) {
        this.map?.fitBounds(L.featureGroup(layers).getBounds(), { padding: [20, 20], animate: false })
      }
    }, 300)
  }

  // stop running animations first, otherwise Leaflet fails after removing the map ("_leaflet_pos")
  disconnect() {
    clearTimeout(this.fitTimeout)
    this.map?.stop()
    this.map?.remove()
    this.map = null
  }

  layer(marker) {
    if (this.hasCircleValue) {
      return L.circle(marker.latlon, marker.count * this.circleValue).bindPopup(marker.popup)
    }
    return L.marker(marker.latlon, { icon: this.icon("marker-icon.png") }).bindPopup(marker.popup)
  }

  icon(iconUrl) {
    const Icon = L.Icon.Default.extend({ options: { iconUrl, shadowUrl: "marker-shadow.png" } })
    return new Icon()
  }
}
