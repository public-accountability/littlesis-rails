import { Controller } from "@hotwired/stimulus"
import { get } from '../src/common/http.mjs'


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
                    "newDocumentUrl",
                    "newDocumentName",
                    "newReferenceButton",
                    "justCleaningUp",
                    "titleExtractorButton"]

  connect() {
    $(this.selectTarget).select2(select2Configuration)
    $(this.selectTarget).on('change', this.selectExistingSource.bind(this))
    this.selectExistingSource()
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

  titleExtractor(event) {
    event.preventDefault()
    event.target.blur()

    const icon = event.target.querySelector('i')

    if (icon && icon.classList.contains('bi-cloud-download')) {
      if (this.newDocumentUrlTarget.value.slice(0,4).toLowerCase() !== 'http') {
        this.newDocumentInputTarget.focus()
        return
      }

      icon.remove()
      this.titleExtractorButtonTarget.innerHTML = '<div class="spinner-border spinner-border-sm" role="status">'
      this.fetchTitle()
    }
  }

  fetchTitle() {
    const url = this.newDocumentUrlTarget.value

    get(`/title_extractor/${url}`)
      .then(json => {
        this.newDocumentNameTarget.value = json.title
        this.titleExtractorButtonTarget.innerHTML = '<i class="bi bi-check-lg" ></i>'
      })
      .catch( err => {
        console.error(err)
        this.titleExtractorButtonTarget.innerHTML = '<i class="bi bi-x-lg" ></i>'
      })
      .finally(() => $(this.titleExtractorButtonTarget).fadeOut(2000, () => this.titleExtractorButtonTarget.remove()))
  }

}
