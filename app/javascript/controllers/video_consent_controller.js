import { Controller } from "@hotwired/stimulus"

// two-click solution for YouTube videos (ui/_youtube_video): the iframe is only created after a click,
// so no connection to YouTube is made before
export default class extends Controller {
  static values = { id: String, title: String }
  static targets = ["placeholder"]

  load() {
    const iframe = document.createElement("iframe")
    iframe.src = `https://www.youtube-nocookie.com/embed/${encodeURIComponent(this.idValue)}?autoplay=1`
    iframe.title = this.titleValue
    iframe.allow = "autoplay; encrypted-media; picture-in-picture; fullscreen"
    iframe.allowFullscreen = true
    iframe.referrerPolicy = "strict-origin-when-cross-origin"
    this.placeholderTarget.replaceWith(iframe)
  }
}
