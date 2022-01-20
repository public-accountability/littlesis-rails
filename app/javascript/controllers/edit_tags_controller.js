import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "modal", "select" ]

  initialize() {
    $(this.selectTarget).select2({
      dropdownAutoWidth : true,
      dropdownParent: $(this.modalTarget)
    })
  }
}
