import { Controller } from "@hotwired/stimulus"

// adds another file row from a <template>; INDEX in names/ids is replaced by a new number
export default class extends Controller {
  static targets = ["rows", "template"]

  add() {
    const index = this.rowsTarget.children.length
    const html = this.templateTarget.innerHTML.replaceAll("INDEX", index)
    this.rowsTarget.insertAdjacentHTML("beforeend", html)
  }
}
