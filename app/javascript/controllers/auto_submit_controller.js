import { Controller } from "@hotwired/stimulus"

// submits the form when a field changes (e.g. selection of the competition for the import)
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
