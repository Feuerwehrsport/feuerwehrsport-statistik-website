import { Controller } from "@hotwired/stimulus"

// <dialog> around the turbo frame "contribution": opens when the frame got content, resets it on close
export default class extends Controller {
  static targets = ["frame"]

  open() {
    if (!this.element.open) this.element.showModal()
  }

  close() {
    this.element.close()
  }

  reset() {
    this.frameTarget.removeAttribute("src")
    this.frameTarget.innerHTML = ""
  }
}
