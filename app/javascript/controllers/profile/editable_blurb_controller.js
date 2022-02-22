import { Controller } from "@hotwired/stimulus"
import { patch } from '../../src/common/http.mjs'

export default class extends Controller {
  static targets = [ "blurb", "pencil" ]

  static values = {
    entityid: Number
  }

  editBlurb() {
    const existingBlurb = this.blurbTarget.textContent
    const controller = new AbortController()

    const cleanup = () => {
      $(this.pencilTarget).show()
      this.blurbTarget.contentEditable = 'false'
      this.blurbTarget.blur()
      controller.abort()
    }

    const onEdit = (event) => {
      if (event.key === 'Enter') {
        event.preventDefault()
      }

      if (event.key === 'Enter' && this.blurbTarget.textContent !== existingBlurb) {
        this.submitBlurb(this.blurbTarget.textContent)
        cleanup()
      } else if (event.key === 'Enter' || event.key === 'Escape') {
        this.blurbTarget.textContent = existingBlurb
        cleanup()
      }
    }

    $(this.pencilTarget).hide()
    this.blurbTarget.contentEditable = 'true'
    this.blurbTarget.focus()
    this.blurbTarget.addEventListener('keydown', onEdit, { signal: controller.signal })
  }


  submitBlurb(text) {
    return patch(`/entities/${this.entityidValue}`, {
      "entity": { "blurb": text },
      "reference": { "just_cleaning_up": 1 }
    })
  }
}
