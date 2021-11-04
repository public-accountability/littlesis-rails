import { Controller } from "@hotwired/stimulus"
import { delay }  from 'lodash-es'

export default class extends Controller {
  static values = { entityName: String }

  example_search() {
    this.element.querySelector('form input[type="text"]').value = this.entityNameValue
    delay(() => this.element.querySelector('form').submit(), 300)
  }

  toggleHideMatched(event) {
    if (event.target.classList.contains('bi-toggle-off')) {
      event.target.classList.remove('bi-toggle-off')
      event.target.classList.add('bi-toggle-on')
    } else {
      event.target.classList.remove('bi-toggle-on')
      event.target.classList.add('bi-toggle-off')
    }
    $('#fec-contributions-table').DataTable().draw()
  }
}
