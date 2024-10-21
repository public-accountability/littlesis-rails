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

  close() {
    window.location.reload()
  }

  // hide modal when clicking ESC
  // action: "keyup@window->modal#closeWithKeyboard"
  closeWithKeyboard(e) {
    console.log(e);
    if (e.code === "Escape") {
      this.close()
    }
  }
  // hide modal when clicking outside of modal
  // action: "click@window->modal#closeBackground"
  closeBackground(e) {
    console.log(e);
    if (e && this.modalTarget.contains(e.target)) {
      return
    }
    this.close()
  }
}
