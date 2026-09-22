import { Controller } from "@hotwired/stimulus"
import { get } from '../src/common/http.mjs'


const select2Configuration = {
  "minimumResultsForSearch": 10,
  "placeholder": "Select a source",
  "allowClear": true
}

const disallowedDomains = <%= Document.disallowed_domains.to_json %>

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
    
    // If there's a URL value, show the new document form
    if (this.newDocumentUrlTarget?.value?.trim()) {
      this.toggleNewDocument()
    }
    
    // Remove error styling when URL changes
    if (this.newDocumentUrlTarget) {
      this.newDocumentUrlTarget.addEventListener('input', () => {
        this.newDocumentUrlTarget.classList.remove('is-invalid')
        const errorMessage = this.newDocumentUrlTarget.nextElementSibling
        if (errorMessage && errorMessage.classList.contains('invalid-feedback')) {
          errorMessage.remove()
        }
      })
    }
    
    this.formElement = this.element.closest('form')
    if (this.formElement) {
      this.formElement.addEventListener('submit', this.validateUrl.bind(this))
    }
  }

  validateUrl(event) {
    const url = this.newDocumentUrlTarget?.value?.trim()
    if (!url) return
    
    try {
      const urlObj = new URL(url)
      const hostname = urlObj.hostname.toLowerCase()
      
      if (disallowedDomains.some(domain => hostname === domain || hostname.endsWith('.' + domain))) {
        event.preventDefault()
        this.showInlineError('Source URL cannot be from a disallowed source (wikipedia.org, etc.)')
        this.newDocumentUrlTarget.focus()
        return false
      }
    } catch (err) {
      // Invalid URL, will be caught by HTML5 validation
    }
  }

  showInlineError(message) {
    // Add error styling to the URL input
    this.newDocumentUrlTarget.classList.add('is-invalid')
    
    // Create error message element if it doesn't exist
    let errorMessage = this.newDocumentUrlTarget.nextElementSibling
    if (!errorMessage || !errorMessage.classList.contains('invalid-feedback')) {
      errorMessage = document.createElement('div')
      errorMessage.className = 'invalid-feedback d-block'
      this.newDocumentUrlTarget.after(errorMessage)
    }
    errorMessage.textContent = message
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
