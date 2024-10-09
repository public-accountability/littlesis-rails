import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  close() {
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
  }
}
