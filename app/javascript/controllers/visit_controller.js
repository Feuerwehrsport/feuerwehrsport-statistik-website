import { Controller } from "@hotwired/stimulus"

// loads another page after a successful change inside a turbo frame (e.g. the new competition of an import)
export default class extends Controller {
  static values = { url: String }

  connect() {
    window.location.assign(this.urlValue)
  }
}
