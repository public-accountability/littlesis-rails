/* Javascript for the Corporate Mapping Project landing page */

import cmp_entities from './src/cmp/data.json'

import { entitySearchSuggestion, processResults } from './src/common/search.mjs'

const entityLink = (row) => {
  return `
<div class="cmp-strata-entity-link">
  <a href=${row.url} target='_blank'>${row.name}</a>
  <div class="cmp-strata-blurb">${row.blurb || ''}</div>
</div>` }

const renderName = (data, type, row, meta) => type === 'display' ? entityLink(row) : data

const columns = [ { "data": "name", "title": "Name", "render": renderName } ];

function initializeDatatable() {
  $('#cmp-strata')
    .dataTable({ "data": cmp_entities,
                 "columns": columns,
                 "language": { "search": "Filter:" } })
}


function initializeEntityTagSearch() {
  $('#cmp-tag-search select')
    .select2({ "templateResult": entitySearchSuggestion,
               "minimumInputLength": 3,
               "ajax": {
                 "url": '/search/entity',
                 "dataType": 'json',
                 "data": function(params) {
                   return { "q": params.term,
                            "num": 5,
                            "tags": 'corporate-mapping-project' }
                 },
                 "processResults": processResults
               }
             })

  $('#cmp-tag-search select').on('select2:select', function(event) {
    window.open(event.params.data.url, '_blank'); })
}

document.addEventListener("DOMContentLoaded", () => {
  initializeDatatable()
  initializeEntityTagSearch()
})
