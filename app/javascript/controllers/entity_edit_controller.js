import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect(){
    $('#entity_regions').select2()
  }

  checkType(event) {
    $(event.target).toggleClass(['bi-check-square', 'bi-square'])

    $('#entity_extension_def_ids').val(
      $('#entity-types .bi-check-square').toArray().map(sq => sq.dataset.definitionId).join(',')
    )
  }

  toggleTypesIcon() {
    $('#type-collapse-icon').toggleClass('bi-box-arrow-down')
    $('#type-collapse-icon').toggleClass('bi-box-arrow-up')
  }
}
