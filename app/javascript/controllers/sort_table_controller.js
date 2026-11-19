import { Controller } from "@hotwired/stimulus"

// sortable, paginated table (DataTables 2, classic script from layouts/_head, Bootstrap 5 styling).
// Optional edit mode: a button below the table turns the time cells into links to a dialog (editUrl with ":id").
export default class extends Controller {
  static values = {
    col: { type: Number, default: 0 },
    direction: { type: String, default: "desc" },
    noSorting: { type: Array, default: [] },
    count: { type: Number, default: 10 },
    editLabel: String,
    editUrl: String,
  }

  connect() {
    if (window.DataTable.isDataTable(this.element)) return

    const options = {
      order: [[this.colValue, this.directionValue]],
      autoWidth: false,
      paging: true,
      pageLength: this.countValue,
    }
    if (this.noSortingValue.length > 0) options.columnDefs = [{ orderable: false, targets: this.noSortingValue }]
    if (this.hasEditUrlValue) options.layout = { bottomStart: ["info", () => this.editButton()] }
    this.table = new window.DataTable(this.element, options)
  }

  // DataTables moves the table into its wrapper, stimulus then disconnects and connects it again:
  // only destroy when the table is really gone
  disconnect() {
    if (this.element.isConnected) return

    this.table?.destroy()
    this.table = null
  }

  editButton() {
    const button = document.createElement("button")
    button.type = "button"
    button.className = "btn btn-outline-primary btn-sm ms-3"
    button.textContent = this.editLabelValue
    button.addEventListener("click", () => {
      button.remove()
      this.table.rows().nodes().each((row) => this.addEditLink(row))
    })
    return button
  }

  addEditLink(row) {
    const cell = row.querySelector(".time-col")
    if (!cell || !row.dataset.scoreId) return

    const link = document.createElement("a")
    link.href = this.editUrlValue.replace(":id", row.dataset.scoreId)
    link.dataset.turboFrame = "contribution"
    link.dataset.turbo = "true"
    link.className = "btn btn-outline-secondary btn-sm"
    link.title = this.editLabelValue
    link.textContent = `✎ ${cell.textContent.trim()}`
    cell.replaceChildren(link)
  }
}
