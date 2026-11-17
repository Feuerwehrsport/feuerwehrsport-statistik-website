import { Controller } from "@hotwired/stimulus"

// keeps a bootstrap dropdown open while its content (e.g. the filter form) is used
export default class extends Controller {
  stop(event) {
    event.stopPropagation()
  }
}
