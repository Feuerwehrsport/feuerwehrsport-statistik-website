import { Controller } from "@hotwired/stimulus"

// rich text editor (Trix, vendored) for WysiwygInput; the HTML is stored in the hidden input of the form.
// Trix is only loaded on pages with an editor.
export default class extends Controller {
  async connect() {
    await import("trix")
    // no file attachments: the content is plain HTML in a text column
    this.element.addEventListener("trix-file-accept", (event) => event.preventDefault())
  }
}
