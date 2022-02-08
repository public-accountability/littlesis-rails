import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  collapse() {
    $('i.subcategory-collapse-toggle.bi-arrows-collapse').trigger('click')
  }

  expand() {
    $('i.subcategory-collapse-toggle.bi-arrows-expand').trigger('click')
  }

}
