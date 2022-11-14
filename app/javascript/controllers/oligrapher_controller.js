import { Modal } from "bootstrap"
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { config: Object, pending: Boolean }

  connect() {
    if (this.pendingValue) {
      Modal.getOrCreateInstance(document.getElementById("oligrapher-pending-editor-modal")).show()
    }

    window.Oligrapher.instance = new Oligrapher(this.configValue)
  }
}
