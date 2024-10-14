import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "modal", "select" ]

  initialize() {
    if (this.hasSelectTarget) {
      $(this.selectTarget).select2({
      dropdownAutoWidth : true,
      dropdownParent: $(this.modalTarget)
      })
    }
  }

  hideModal() {
    this.element.nextSibling.nextSibling.remove()
    this.element.parentElement.removeAttribute("src")
    this.element.remove()
  }
}
