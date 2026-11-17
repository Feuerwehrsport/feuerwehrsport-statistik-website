import { Controller } from "@hotwired/stimulus"

// textarea grows with its content
export default class extends Controller {
  connect() {
    this.resize()
  }

  resize() {
    this.element.style.height = "auto"
    this.element.style.height = `${this.element.scrollHeight + 2}px`
  }
}
