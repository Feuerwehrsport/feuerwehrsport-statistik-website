import { Controller } from "@hotwired/stimulus"

// backend: select of associated records with search in a bootstrap modal (AssociationSelectInput).
// The <select> holds the chosen records, the list shows them, the modal searches via AssociationSelectController.
export default class extends Controller {
  static values = { url: String }

  connect() {
    const find = (selector) => this.element.querySelector(selector)
    this.select = find("select")
    this.multiple = this.select.multiple
    this.list = this.element.querySelector(":scope > ul")
    this.listTemplate = this.takeFirst(this.list)
    this.removeAllButton = find(".as-remove-all")

    const addButton = find(".as-add")
    this.modal = find(addButton.getAttribute("href"))
    this.modalList = this.modal.querySelector(".as-ul")
    this.modalListTemplate = this.takeFirst(this.modalList)
    this.search = this.modal.querySelector(".as-search")
    this.groups = this.modal.querySelector(".as-groups")
    this.groupTemplate = this.takeFirst(this.groups)
    this.groups.hidden = true

    addButton.addEventListener("click", (event) => this.openModal(event))
    this.removeAllButton?.addEventListener("click", () => this.removeAll())
    this.search.addEventListener("input", () => this.searchRecords())
    this.updateSelectedList()
  }

  disconnect() {
    this.request?.abort()
  }

  // first child is the template for the entries
  takeFirst(parent) {
    const first = parent.firstElementChild
    first.remove()
    return first
  }

  selectedRecords() {
    return Array.from(this.select.selectedOptions).filter((option) => option.value).map((option) => [
      option.value, option.textContent, option.dataset.info, option.dataset.desc,
    ])
  }

  updateSelectedList() {
    const records = this.selectedRecords()
    if (this.removeAllButton) this.removeAllButton.hidden = records.length <= 1
    this.fillList(this.list, this.listTemplate, records, (id) => {
      this.select.querySelector(`option[value="${CSS.escape(id)}"]`)?.remove()
      this.changed()
      this.updateSelectedList()
    })
  }

  fillList(list, template, records, onClick) {
    list.replaceChildren(...records.map(([id, label, info, desc]) => {
      const item = template.cloneNode(true)
      item.querySelector(".as-info").textContent = info || ""
      item.querySelector(".as-label").textContent = label
      const descElement = item.querySelector(".as-desc")
      if (descElement) {
        descElement.textContent = desc || ""
        descElement.hidden = !desc
      }
      const clickables = item.matches(".as-selectable") ? [item] : item.querySelectorAll(".as-remove")
      clickables.forEach((element) => element.addEventListener("click", () => {
        item.remove()
        onClick(id, label, info, desc)
      }))
      return item
    }))
  }

  addOption(id, label, info, desc) {
    this.select.querySelector(`option[value="${CSS.escape(String(id))}"]`)?.remove()
    const option = new Option(label, id, true, true)
    option.dataset.info = info || ""
    option.dataset.desc = desc || ""
    this.select.append(option)
  }

  showResults(payload) {
    this.fillList(this.modalList, this.modalListTemplate, payload.results || [], (id, label, info, desc) => {
      this.hideModal()
      if (!this.multiple) this.select.replaceChildren()
      this.addOption(id, label, info, desc)
      this.changed()
      this.updateSelectedList()
    })
    if (this.multiple) this.showGroups(payload.groups || {})
  }

  showGroups(groups) {
    const names = Object.keys(groups)
    this.groups.hidden = names.length === 0
    this.groups.replaceChildren(...names.map((name) => {
      const button = this.groupTemplate.cloneNode(true)
      button.textContent = name
      button.addEventListener("click", () => {
        groups[name].forEach(([id, label, info, desc]) => this.addOption(id, label, info, desc))
        this.updateSelectedList()
        this.hideModal()
      })
      return button
    }))
  }

  async searchRecords() {
    this.request?.abort()
    this.request = new AbortController()
    this.modal.classList.add("is-loading")
    const separator = this.urlValue.includes("?") ? "&" : "?"
    try {
      const response = await fetch(`${this.urlValue}${separator}q=${encodeURIComponent(this.search.value)}`,
                                   { signal: this.request.signal, headers: { Accept: "application/json" } })
      const json = await response.json()
      if (json.payload) this.showResults(json.payload)
      this.modal.classList.remove("is-loading")
    } catch (error) {
      if (error.name !== "AbortError") throw error
    }
  }

  openModal(event) {
    event.preventDefault()
    this.search.value = ""
    window.bootstrap.Modal.getOrCreateInstance(this.modal).show()
    setTimeout(() => this.search.focus(), 300)
    this.searchRecords()
  }

  hideModal() {
    window.bootstrap.Modal.getOrCreateInstance(this.modal).hide()
  }

  removeAll() {
    this.hideModal()
    this.select.replaceChildren()
    this.updateSelectedList()
    this.changed()
  }

  // other code may react on the changed selection (like the former jQuery "change" trigger)
  changed() {
    setTimeout(() => this.select.dispatchEvent(new Event("change", { bubbles: true })), 300)
  }
}
