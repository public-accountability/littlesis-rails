import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    $('.dropdown-toggle').dropdown()
  }
}
