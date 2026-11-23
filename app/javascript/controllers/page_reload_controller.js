import { Controller } from "@hotwired/stimulus"

// reloads the page after a successful change, so the (re-generated) page shows the new data;
// with a url (e.g. the record left a list) that page is loaded instead
export default class extends Controller {
  static values = { url: String }

  connect() {
    if (this.urlValue) {
      window.location.href = this.urlValue
    } else {
      window.location.reload()
    }
  }
}
