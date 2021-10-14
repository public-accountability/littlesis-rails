/*
Javascript for the Corporate Mapping Project landing page
*/

import 'select2'
import datatable from 'datatables.net'
import cmp_entities from './cmp/data.json'

const entityLink = (row) => {
  return `
<div class="cmp-strata-entity-link">
  <a href=${row.url} target='_blank'>${row.name}</a>
  <div class="cmp-strata-blurb">${row.blurb || ''}</div>
</div>`
}

const renderName = (data, type, row, meta) => type === 'display' ? entityLink(row) : data

const columns = [
  { "data": "name", "title": "Name", "render": renderName }
];

const initializeDatatable = () => {
  $('#cmp-strata').dataTable({
    "data": cmp_entities,
    "columns": columns,
    "language": {
      "search": "Filter:"
    }
  })
}

const entitySearchSuggestion = (entity) => {
  return $(`
<div class="entity-search-suggestion">
  <div class="entity-search-suggestion-name">
    <span class="entity-search-suggestion-name-text font-weight-bold">${entity.name}</span>
  </div>
  <div class="entity-search-suggestion-blurb">${entity.blurb}</div>
</div>`)}

const initializeEntityTagSearch = () => {
  $('#cmp-tag-search select').select2({
    templateResult: entitySearchSuggestion,
    minimumInputLength: 3,
    ajax:{
      url: "/search/entity",
      dataType: 'json',
      data: function(params) {
        return {
          "q": params.term,
          "num": 5,
          "tags": 'corporate-mapping-project'
        }
      },

      processResults: function(data) {
        let results = data.map( entity => {
          entity.text = entity.name
          return entity
        })

        return { "results": results }
      }
    }
  })

  $('#cmp-tag-search select').on('select2:select', function(event) {
    window.open(event.params.data.url, '_blank');
  })
}

const main = () => {
  initializeDatatable()
  initializeEntityTagSearch()
}

document.addEventListener("DOMContentLoaded", main)
