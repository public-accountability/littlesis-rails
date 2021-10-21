import { Controller } from "@hotwired/stimulus"
import $ from 'jquery'

export default class extends Controller {
  static targets = [ "modal", "select"]

  initialize() {
    $(this.selectTarget).select2({ dropdownAutoWidth : true })
  }

  open() {
    $(this.modalTarget).modal('toggle')
  }

}
