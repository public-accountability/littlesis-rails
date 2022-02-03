import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  initialize() {
    $(this.element).select2({
      placeholder: 'Search for a list',
      ajax: {
        url: '/lists?editable=true',
        dataType: 'json'
      }
    })
  }

}
