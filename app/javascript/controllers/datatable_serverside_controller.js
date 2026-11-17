import { Controller } from "@hotwired/stimulus"

// table with server side paging/sorting (DataTables 2), options in data-datatable-options
export default class extends Controller {
  connect() {
    if (window.DataTable.isDataTable(this.element)) return

    const options = {
      autoWidth: false,
      paging: true,
      pageLength: 10,
      serverSide: true,
      ...JSON.parse(this.element.dataset.datatableOptions || "{}"),
    }
    options.ajax.data = (data) => {
      delete data.columns
      return data
    }
    this.table = new window.DataTable(this.element, options)
  }

  // see sort_table_controller.js
  disconnect() {
    if (this.element.isConnected) return

    this.table?.destroy()
    this.table = null
  }
}
