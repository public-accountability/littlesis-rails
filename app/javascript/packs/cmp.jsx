/*
Javascript for the Corporate Mapping Project landing page
*/
import React from 'react'
import ReactDOM from 'react-dom'
import datatable from 'datatables.net'

import cmp_entities from './cmp/data.json'
// import EntityTagSearch from './tags/EntityTagSearch';
import { EntitySearch } from './search/EntitySearch'

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

const initializeEntityTagSearch = () => {
  ReactDOM.render(
    <EntitySearch tag="corporate-mapping-project"/>,
    document.getElementById('cmp-tag-search')
  )
}

const main = () => {
  initializeDatatable()
  initializeEntityTagSearch()
}

document.addEventListener("DOMContentLoaded", main)
