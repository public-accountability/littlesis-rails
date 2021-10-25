import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { acceptedExtensions: Array }

  connect() {
    const extensions = this.acceptedExtensionsValue

    Parsley
      .addValidator('filetype', function(value){
        const fileExtension = value.split('.').pop().toLowerCase()
        return extensions.includes(fileExtension)
      })
      .addMessage(
        'en',
        'filetype',
        'Invalid image file type. Please select a file with one of the following extensions: ' + extensions.join(', ')
      )
  }
}
