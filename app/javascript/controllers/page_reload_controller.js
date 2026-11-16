import { Controller } from "@hotwired/stimulus"

// reloads the page after a successful change, so the (re-generated) page shows the new data
export default class extends Controller {
  connect() {
    window.location.reload()
  }
}
