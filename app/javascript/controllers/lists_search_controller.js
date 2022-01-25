import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form", "orderDirection", "orderColumn" ]

  setDirection(event) {
    if (event.target.classList.contains('bi-sort-down')) {
      var nextDirection = 'asc'
    } else if (event.target.classList.contains('bi-sort-up'))  {
      var nextDirection = null
    } else {
      var nextDirection = 'desc'
    }
    this.orderDirectionTarget.value = nextDirection
    this.orderColumnTarget.value = event.target.dataset.column
    this.formTarget.submit()
  }
}
