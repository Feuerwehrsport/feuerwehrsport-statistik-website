import { Controller } from "@hotwired/stimulus"

// backend: loads an index table of associated records into the page, sorting and paging stay inside
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.load(this.jsUrl(this.urlValue))
  }

  disconnect() {
    this.request?.abort()
  }

  // the index actions answer the .js format with the plain table
  jsUrl(url) {
    const [path, query] = url.split("?", 2)
    return `${path.endsWith(".js") ? path : `${path}.js`}${query ? `?${query}` : ""}`
  }

  async load(url) {
    this.request?.abort()
    this.request = new AbortController()
    for (const child of this.element.children) child.style.opacity = 0.5
    try {
      const response = await fetch(url, { signal: this.request.signal, cache: "no-store",
                                           headers: { "X-Requested-With": "XMLHttpRequest" } })
      const html = new DOMParser().parseFromString(await response.text(), "text/html")
      const content = html.querySelector("div.section > div.container")
      this.element.replaceChildren(...(content ? content.children : []))
      this.element.querySelectorAll(".is-sortable a, .pagination a").forEach((link) => {
        link.addEventListener("click", (event) => {
          event.preventDefault()
          this.load(this.jsUrl(link.getAttribute("href")))
        })
      })
    } catch (error) {
      if (error.name !== "AbortError") throw error
    }
  }
}
