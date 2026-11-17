import { Controller } from "@hotwired/stimulus"

// import: columns of the pasted result lines, fields can be added and removed
export default class extends Controller {
  static targets = ["fields", "template"]

  add() {
    this.fieldsTarget.insertAdjacentHTML("beforeend", this.templateTarget.innerHTML)
  }

  remove(event) {
    event.target.closest(".input-line-field").remove()
  }
}
