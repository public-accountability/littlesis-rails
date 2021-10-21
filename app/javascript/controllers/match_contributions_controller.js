import { Controller } from "@hotwired/stimulus"
import delay from 'lodash/delay'

export default class extends Controller {
  static values = { entityName: String }

  example_search() {
    this.element.querySelector('form input[type="text"]').value = this.entityNameValue
    delay(() => this.element.querySelector('form').submit(), 300)
  }
}
