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

function addEntityToList(entityId, listId) {
  Http
    .post(`/lists/${listId}/list_entities`, { "entity_id": entityId })
    .then(() => window.location.reload())
}

export default class extends Controller {
  static values = {
    preselected: Number,
    listid: Number,
    placeholder: { type: String, default: "Search for a person or org" }
  }

  initialize() {
    $(this.element).select2({
      templateResult: entitySearchSuggestion,
      minimumInputLength: 3,
      placeholder: this.placeholderValue,
      allowClear: true,
      ajax: {
        url: ENTITY_SEARCH_URL,
        processResults: processResults
      }
    })

    // For the list actions toolbar:  after selection, it gets automatically added to the list
    if (this.listidValue) {
      $(this.element).on('select2:select', (event) => {
        addEntityToList(event.params.data.id, this.listidValue)
      })
    }

    // $(this.element).on('select2:unselect', () => {
    //   $(this.element).closest('form').submit()
    // })

    // If data-entity-autocomplete-preselected-value is configured, retrieve the entity info from our api and automatically select
    if (this.hasPreselectedValue && this.preselectedValue > 0) {
      Http
        .get(`/api/entities/${this.preselectedValue}`)
        .then(response => selectEntity(this.element, response.data.attributes))
    }
  }
}
