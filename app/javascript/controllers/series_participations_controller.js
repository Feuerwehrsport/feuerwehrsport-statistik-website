import { Controller } from "@hotwired/stimulus"

// backend series round: the entries of the (public) tables open their edit form
export default class extends Controller {
  connect() {
    this.element.querySelectorAll(".series-participation").forEach((element) => {
      element.classList.add("btn", "btn-outline-secondary", "btn-sm")
      element.setAttribute("role", "link")
      element.title = "Eintrag bearbeiten"
    })
  }

  edit(event) {
    const element = event.target.closest(".series-participation")
    if (!element) return

    window.location = `/backend/series/${element.dataset.type}_participations/${element.dataset.id}/edit`
  }
}
