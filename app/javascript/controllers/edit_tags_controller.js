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
    document.querySelector('.modal-backdrop').remove();
    document.querySelector('.modal').remove();
    document.querySelector('#modal').removeAttribute('src');
  }

  // hide modal when clicking ESC
  // action: "keyup@window->modal#closeWithKeyboard"
  closeWithKeyboard(e) {
    if (e.code === "Escape") {
      this.close()
    }
  }
  // hide modal when clicking outside of modal
  // action: "click@window->modal#closeBackground"
  closeBackground(e) {
    if (e && this.modalTarget.contains(e.target)) {
      return
    }
    this.close()
  }
}
