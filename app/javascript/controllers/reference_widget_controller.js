import { Controller } from "stimulus"
import 'select2'

const select2Configuration = {
  "minimumResultsForSearch": 10,
  "placeholder": "Select a source",
  "allowClear": true
}

export default class extends Controller {
  static targets = ["select",
                    "existingSource",
                    "newDocument",
                    "newDocumentInput",
                    "newReferenceButton",
                    "justCleaningUp"]

  connect() {
    $(this.selectTarget).select2(select2Configuration)
    $(this.selectTarget).on('change', this.selectExistingSource.bind(this))
    this.selectExistingSource()
  }

  togglejustcleaningup(event) {
    if (event.target.checked) {
      this.selectTarget.disabled = true
      this.newReferenceButtonTarget.disabled = true
    } else {
      this.selectTarget.disabled = false
      this.newReferenceButtonTarget.disabled = false
    }
  }

  selectExistingSource() {
    if (this.selectTarget.value) {
      this.justCleaningUpTarget.required = false
    } else {
      this.justCleaningUpTarget.required = true
    }
  }

  toggleNewDocument() {
    this.existingSourceTarget.style.display = 'none'
    this.newDocumentTarget.style.display = 'block'
    this.justCleaningUpTarget.required = false
    this.newDocumentInputTargets.map(elem => elem.required = true)
  }

  toggleExistingSource() {
    this.existingSourceTarget.style.display = 'block'
    this.newDocumentTarget.style.display = 'none'
    if (!this.selectTarget.value) {
      this.justCleaningUpTarget.required = true
    }
    this.newDocumentInputTargets.map(elem => elem.required = false)
  }
}
