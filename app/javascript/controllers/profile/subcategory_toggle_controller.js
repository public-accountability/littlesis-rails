import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    const toggleIcon = (event) => {
      // Bootstrap collapse events will propagate up
      if (event.target == this.element) {
        let icon = document.querySelector(`i[data-bs-target=".${this.element.dataset.subcategory}-collapse"]`)
        icon.classList.toggle('bi-arrows-collapse')
        icon.classList.toggle('bi-arrows-expand')
      }
    }
    this.element.addEventListener('shown.bs.collapse', toggleIcon)
    this.element.addEventListener('hidden.bs.collapse', toggleIcon)
  }
}
