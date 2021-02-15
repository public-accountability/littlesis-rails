import { Controller } from 'stimulus'
import Bloodhound from 'bloodhound-js'
import mustache from 'mustache'

export default class extends Controller {
  static values = { endpoint: String, inputId: String, templates: Object }

  connect() {
    const inputElement = $(this.inputIdValue)
    const templates = this.templatesValue

    inputElement.typeahead(null, {
      async: true,
      name: 'entities',
      source: entitySearch(this.endpointValue),
      limit: 8,
      display: 'name',
      templates: {
        empty: $(templates['empty_message']).html(),
        suggestion: function(data) {
          return mustache.render($(templates['entity_suggestion']).html(), data)
        }
      }
    })

    inputElement.bind('typeahead:select', function(ev, suggestion) {
      renderForm($($(templates['form']).html()), suggestion.id).submit()
    })
  }
}

function entitySearch(endpoint) {
  return new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: endpoint, 
      wildcard: '%25QUERY'
    }
  })
}

function renderForm(template, entityId) {
  const action = template.attr('action').replace(/XXX/, entityId)
  template.attr('action', action)
  template.children('[name=entity_id]').val(entityId)

  $(document.body).append(template)
  return template
}
