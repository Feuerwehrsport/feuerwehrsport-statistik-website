import { Controller } from "@hotwired/stimulus"

// file input with preview of the current file (FilePreviewInput): replace, remove or reset
export default class extends Controller {
  connect() {
    const find = (selector) => this.element.querySelector(selector)
    this.input = find("input[type=file]")
    this.editButton = find(".imagepreview-actions-edit")
    this.inputWrapper = find(".imagepreview-input-wrapper")
    this.removeCheckBox = find(".imagepreview-remove")
    this.removeButton = find(".imagepreview-actions-remove")
    this.removeHint = find(".imagepreview-remove-hint")
    this.resetButton = find(".imagepreview-actions-reset")

    if (this.removeCheckBox) {
      this.inputWrapper.hidden = true
      this.removeCheckBox.closest(".checkbox").hidden = true
    }
    if (this.removeHint) this.removeHint.hidden = true
    if (this.resetButton) this.resetButton.hidden = true

    this.editButton?.addEventListener("click", () => { this.unremove(); this.edit() })
    this.removeButton?.addEventListener("click", () => { this.unedit(); this.remove() })
    this.resetButton?.addEventListener("click", () => { this.unedit(); this.unremove(); this.resetButton.hidden = true })
  }

  edit() {
    this.element.classList.add("is-edited")
    this.editButton.classList.add("active")
    this.inputWrapper.hidden = false
    this.resetButton.hidden = false
  }

  unedit() {
    this.element.classList.remove("is-edited")
    this.editButton.classList.remove("active")
    this.inputWrapper.hidden = true
    this.input.value = ""
  }

  remove() {
    this.element.classList.add("is-removed")
    this.removeButton.classList.add("active")
    this.removeHint.hidden = false
    this.removeCheckBox.checked = true
    this.resetButton.hidden = false
  }

  unremove() {
    this.element.classList.remove("is-removed")
    this.removeButton.classList.remove("active")
    this.removeHint.hidden = true
    this.removeCheckBox.checked = false
  }
}
