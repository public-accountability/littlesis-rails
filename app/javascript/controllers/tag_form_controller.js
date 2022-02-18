import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { names: Array }

  initialize() {
    this.installTagNamesValidator()
  }

  connect() {
    $(this.element).parsley()
  }

  installTagNamesValidator() {
    const names = this.namesValue

    window
      .Parsley
      .addValidator('tagNames', {
        requirementType: 'boolean',
        validateString: function(value) {
          return !names.includes(value.trim().toLowerCase().replaceAll(' ', '-'))
        },
        messages: {
          en: 'a tag already exists with that name'
        }
      })
  }
}
