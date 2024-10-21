import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {

  close(event) {
    window.location.reload()
  }

  // hide modal when clicking ESC
  // action: "keyup@window->turbo-modal#closeWithKeyboard"
  closeWithKeyboard(e) {
    console.log(e);
    if (e.code === "Escape") {
      this.close()
    }
  }
  // hide modal when clicking outside of modal
  // action: "click@window->turbo-modal#closeBackground"
  closeBackground(e) {
    console.log(e);
    if (e && this.modalTarget.contains(e.target)) {
      return
    }
    this.close()
  }
}
