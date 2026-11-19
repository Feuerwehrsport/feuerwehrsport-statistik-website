import { Controller } from "@hotwired/stimulus"

const TILES = "https://b.tile.openstreetmap.de/tiles/osmde/{z}/{x}/{y}.png"
const ATTRIBUTION = 'Map data © <a href="http://openstreetmap.org">openstreetmap</a>'
const DEFAULT_POSITION = [51, 13]

// map of a team or place (Leaflet, global L): shows the position, makes the marker draggable for editing and
// opens the dialog Contributions::GeoPositionsController to save it
export default class extends Controller {
  static targets = ["map", "save", "start"]
  static values = { url: String }

  connect() {
    const data = JSON.parse(this.mapTarget.dataset.map || "{}")
    this.red = data.red
    if (this.red) {
      this.show(this.red.latlon)
      this.marker.bindPopup(this.red.popup)
    } else {
      this.mapTarget.hidden = true
    }
  }

  // stop running animations first, otherwise Leaflet fails after removing the map ("_leaflet_pos")
  disconnect() {
    this.map?.stop()
    this.map?.remove()
    this.map = null
    this.marker = null
  }

  edit(event) {
    event?.preventDefault()
    this.show(this.marker ? this.marker.getLatLng() : DEFAULT_POSITION)
    this.marker.dragging.enable()
    this.saveTarget.hidden = false
    if (this.hasStartTarget) this.startTarget.hidden = true
    this.mapTarget.scrollIntoView({ block: "center" })
  }

  // position chosen elsewhere (e.g. place search in the backend): edit from there
  move({ detail: { latlon, country, state } }) {
    this.place = { country, state }
    this.edit()
    this.marker.setLatLng(latlon)
    this.map.panTo(latlon, { animate: false })
  }

  save() {
    const { lat, lng } = this.marker.getLatLng()
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("latitude", lat)
    url.searchParams.set("longitude", lng)
    if (this.place?.country) url.searchParams.set("place_country", this.place.country)
    if (this.place?.state) url.searchParams.set("place_state", this.place.state)
    document.getElementById("contribution").src = url.toString()
  }

  show(latlon) {
    this.mapTarget.hidden = false
    if (!this.map) {
      this.map = L.map(this.mapTarget, { center: latlon, zoom: 8, scrollWheelZoom: false,
                                         layers: [L.tileLayer(TILES, { attribution: ATTRIBUTION })] })
    } else {
      this.map.panTo(latlon, { animate: false })
    }
    if (!this.marker) this.marker = L.marker(latlon, { icon: this.redIcon() }).addTo(this.map)
  }

  redIcon() {
    const RedIcon = L.Icon.Default.extend({ options: { iconUrl: "marker-icon-red.png", shadowUrl: "marker-shadow.png" } })
    return new RedIcon()
  }
}
