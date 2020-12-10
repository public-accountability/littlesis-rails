import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["select", "existingSource", "newDocument", "newReferenceButton"]

  connect() {
    window.$(this.selectTarget).select2({
      "minimumResultsForSearch": 10,
      "placeholder": "Select a source",
      "allowClear": true
    })
  }

  toggleJustCleaningUp(event) {
    if (event.target.checked) {
      this.selectTarget.disabled = true
      this.newReferenceButtonTarget.disabled = true
    } else {
      this.selectTarget.disabled = false
      this.newReferenceButtonTarget.disabled = false
    }
  }

  toggleNewDocument() {
    this.existingSourceTarget.style.display = 'none'
    this.newDocumentTarget.style.display = 'block'
  }

  toggleExistingSource() {
    this.existingSourceTarget.style.display = 'block'
    this.newDocumentTarget.style.display = 'none'
  }
}
