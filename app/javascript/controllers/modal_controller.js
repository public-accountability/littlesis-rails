import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {

  close(event) {
    document.querySelector('.modal-backdrop')?.remove();
    document.querySelector('.modal').remove();
    document.querySelector('#modal').removeAttribute('src');
  }

  // hide modal when clicking ESC
  // action: "keyup@window->turbo-modal#closeWithKeyboard"
  closeWithKeyboard(e) {
    if (e.code === "Escape") {
      this.close()
    }
  }
  // hide modal when clicking outside of modal
  // action: "click@window->turbo-modal#closeBackground"
  closeBackground(e) {
    if (e && this.modalTarget.contains(e.target)) {
      return
    }
    this.close()
  }
}
