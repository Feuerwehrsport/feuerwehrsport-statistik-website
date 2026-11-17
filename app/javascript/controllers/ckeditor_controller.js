import { Controller } from "@hotwired/stimulus"

let loading = null

// rich text editor (CKEditor 4 from /ckeditor) for WysiwygInput
export default class extends Controller {
  async connect() {
    window.CKEDITOR_BASEPATH = "/ckeditor/"
    loading ||= new Promise((resolve, reject) => {
      const script = document.createElement("script")
      script.src = "/ckeditor/ckeditor.js"
      script.onload = resolve
      script.onerror = reject
      document.head.append(script)
    })
    await loading
    this.editor = window.CKEDITOR.replace(this.element)
  }

  disconnect() {
    this.editor?.destroy()
    this.editor = null
  }
}
