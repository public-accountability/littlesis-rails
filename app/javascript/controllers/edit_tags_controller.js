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
}
