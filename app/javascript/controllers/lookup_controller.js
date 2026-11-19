import { Controller } from "@hotwired/stimulus"

const SERVICES = {
  wikipedia: (query) => "https://de.wikipedia.org/w/api.php?action=query&format=json&list=search&utf8=1&origin=*" +
                        `&srsearch=${encodeURIComponent(query)}`,
  nominatim: (query) => `https://nominatim.openstreetmap.org/search?format=json&addressdetails=1&q=${encodeURIComponent(query)}`,
}

// backend: searches a team name on wikipedia or nominatim (places) and shows the results as table rows.
// Nominatim results can be chosen for the map (event geo-position:move), including their country/state.
export default class extends Controller {
  static targets = ["results"]
  static values = { service: String, query: String }

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
    return json.map((item) => {
      const button = document.createElement("button")
      button.type = "button"
      button.className = "btn btn-outline-secondary btn-sm"
      button.textContent = "Auswählen"
      button.dataset.action = "lookup#choose"
      button.dataset.lookupLatParam = item.lat
      button.dataset.lookupLonParam = item.lon
      button.dataset.lookupCountryParam = item.address?.country_code || ""
      button.dataset.lookupStateParam = item.address?.state || ""
      return [this.cell(item.display_name), this.cell(button)]
    })
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
