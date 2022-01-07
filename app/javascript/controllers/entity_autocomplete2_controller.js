import { Controller } from "@hotwired/stimulus"
import { entitySearchSuggestion, processResults, ENTITY_SEARCH_URL } from '../src/common/search.mjs'
import Http from '../src/common/http.mjs'

function selectEntity(element, attributes) {
  // see: https://select2.org/programmatic-control/add-select-clear-items#preselecting-options-in-an-remotely-sourced-ajax-select2
  let option = new Option(attributes.name, attributes.id, true, true)
  $(element).append(option).trigger('change')
  $(element).trigger({
    type: 'select2:select',
    params: { data: attributes }
  })
}

export default class extends Controller {
  static values = {
    preselected: Number
  }

  initialize() {
    $(this.element).select2({
      templateResult: entitySearchSuggestion,
      minimumInputLength: 3,
      placeholder: "Search for a person or org",
      allowClear: true,
      ajax: {
        url: ENTITY_SEARCH_URL,
        processResults: processResults
      }
    })

    $(this.element).on('select2:unselect', () => {
      $(this.element).closest('form').submit()
    })

    if (this.hasPreselectedValue && this.preselectedValue > 0) {
      Http
        .get(`/api/entities/${this.preselectedValue}`)
        .then(response => selectEntity(this.element, response.data.attributes))
    }
  }
}
