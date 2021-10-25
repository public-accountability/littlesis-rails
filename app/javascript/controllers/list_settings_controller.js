import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { listAccessName: String }

  connect() {
    showHelp(this.listAccessNameValue)
  }

  switchAccess(event) {
    markSelected(event.target)
    showHelp(event.target.getAttribute('value'))
  }
}

function markSelected(element) {
  $('.btn-primary').removeClass('btn-primary')
  $(element).addClass('btn-primary')
}

function showHelp(name){
  $('.list-access-level-help').hide()
  $(`#list-access-level-help-${name}`).show()
}
