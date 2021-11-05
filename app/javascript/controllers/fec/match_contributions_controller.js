import { Controller } from "@hotwired/stimulus"
import { delay }  from 'lodash-es'

export default class extends Controller {
  static values = { entityName: String }

  example_search() {
    this.element.querySelector('form input[type="text"]').value = this.entityNameValue
    delay(() => this.element.querySelector('form').submit(), 300)
  }

  toggleIncludeHidden(event) {
    this.toggleClasses(event.target)
    $('#fec-contributions-table').DataTable().draw()
  }

  toggleHideMatched(event) {
    this.toggleClasses(event.target)
    $('#fec-contributions-table').DataTable().draw()
  }

  toggleClasses(target) {
    if (target.classList.contains('bi-toggle-off')) {
      target.classList.remove('bi-toggle-off')
      target.classList.add('bi-toggle-on')
    } else {
      target.classList.remove('bi-toggle-on')
      target.classList.add('bi-toggle-off')
    }
  }

}
