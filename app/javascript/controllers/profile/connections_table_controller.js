import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    $(this.element).find('table').DataTable()
  }
}
