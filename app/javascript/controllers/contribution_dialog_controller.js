import { Controller } from "@hotwired/stimulus"

// <dialog> around the turbo frame "contribution": opens when the frame got content, resets it on close
export default class extends Controller {
  static targets = ["frame"]

  open() {
    if (!this.element.open) this.element.showModal()
    this.focus()
  }

  close() {
    this.element.close()
  }

  reset() {
    this.frameTarget.removeAttribute("src")
    this.frameTarget.innerHTML = ""
  }

  // showModal() focuses the first focusable element (e.g. the first choice, shown as selected).
  // Focus an element with autofocus instead, otherwise the dialog itself.
  focus() {
    const autofocus = this.frameTarget.querySelector("[autofocus]")
    if (autofocus) {
      autofocus.focus()
    } else {
      this.element.focus()
    }
  }
}
