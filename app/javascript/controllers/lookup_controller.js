import { Controller } from "@hotwired/stimulus"

const SERVICES = {
  wikipedia: (query) => "https://de.wikipedia.org/w/api.php?action=query&format=json&list=search&utf8=1&origin=*" +
                        `&srsearch=${encodeURIComponent(query)}`,
  nominatim: (query) => `https://nominatim.openstreetmap.org/search?format=json&addressdetails=1&q=${encodeURIComponent(query)}`,
}

// backend: searches a team name on wikipedia or nominatim (places) and shows the results as table rows.
// Nominatim results can be chosen for the map (event geo-position:move), including their country/state.
// With anchors (competition places of the team) they are sorted by the distance to the nearest one.
export default class extends Controller {
  static targets = ["results"]
  static values = { service: String, query: String, anchors: Array }

  async connect() {
    try {
      const response = await fetch(SERVICES[this.serviceValue](this.queryValue))
      const json = await response.json()
      this.render(this.serviceValue === "wikipedia" ? this.wikipediaRows(json) : this.nominatimRows(json))
    } catch {
      this.render([[this.cell("Suche fehlgeschlagen")]])
    }
  }

  // the state of the place is passed along, the save dialog offers it for the team
  choose({ params: { lat, lon, country, state } }) {
    window.dispatchEvent(new CustomEvent("geo-position:move", { detail: { latlon: [lat, lon], country, state } }))
  }

  wikipediaRows(json) {
    return (json.query?.search || []).map((item) => {
      const link = document.createElement("a")
      link.href = `https://de.wikipedia.org/?curid=${item.pageid}`
      link.target = "_blank"
      link.textContent = item.title
      // the snippet contains html (highlighting), only its text is used
      const snippet = new DOMParser().parseFromString(item.snippet, "text/html").body.textContent
      return [this.cell(link), this.cell(snippet)]
    })
  }

  nominatimRows(json) {
    const items = json.map((item) => ({ item, nearest: this.nearestAnchor(item) }))
    if (this.anchorsValue.length > 0) items.sort((a, b) => a.nearest.distance - b.nearest.distance)
    return items.map(({ item, nearest }) => {
      const button = document.createElement("button")
      button.type = "button"
      button.className = "btn btn-outline-secondary btn-sm"
      button.textContent = "Auswählen"
      button.dataset.action = "lookup#choose"
      button.dataset.lookupLatParam = item.lat
      button.dataset.lookupLonParam = item.lon
      button.dataset.lookupCountryParam = item.address?.country_code || ""
      button.dataset.lookupStateParam = item.address?.state || ""
      const cells = [this.cell(item.display_name)]
      if (nearest) cells.push(this.cell(`ca. ${Math.round(nearest.distance)} km von ${nearest.name}`))
      return [...cells, this.cell(button)]
    })
  }

  // nearest competition place of a result: { name, distance (km) }, null without anchors
  nearestAnchor(item) {
    const distances = this.anchorsValue.map((anchor) => ({
      name: anchor.name,
      distance: this.distanceKm(Number(item.lat), Number(item.lon), anchor.lat, anchor.lon),
    }))
    return distances.sort((a, b) => a.distance - b.distance)[0] || null
  }

  // great circle distance (haversine)
  distanceKm(lat1, lon1, lat2, lon2) {
    const rad = Math.PI / 180
    const a = Math.sin((lat2 - lat1) * rad / 2) ** 2 +
              Math.cos(lat1 * rad) * Math.cos(lat2 * rad) * Math.sin((lon2 - lon1) * rad / 2) ** 2
    return 2 * 6371 * Math.asin(Math.sqrt(a))
  }

  cell(content) {
    const td = document.createElement("td")
    td.append(content)
    return td
  }

  render(rows) {
    if (rows.length === 0) rows = [[this.cell("Nichts gefunden")]]
    this.resultsTarget.replaceChildren(...rows.map((cells) => {
      const tr = document.createElement("tr")
      tr.append(...cells)
      return tr
    }))
  }
}
