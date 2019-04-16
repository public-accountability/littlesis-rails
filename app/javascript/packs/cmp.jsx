/*
Javascript for the cmp landing page

Assumes datatables and jquery has been loaded in window
*/
const $ = window.$;

import React from 'react';
import ReactDOM from 'react-dom';

import cmp_entities from './cmp/data.json';
// import EntityTagSearch from './tags/EntityTagSearch';
import { EntitySearch } from './search/EntitySearch';

const entityLink = (row) => {
  return `
<div class="cmp-strata-entity-link">
  <a href=${row.url} target='_blank'>${row.name}</a>
  <div class="cmp-strata-blurb">${row.blurb || ''}</div>
</div>`;
};

const strataMap = {
  "1": "Core Sample",
  "2": "Canadian direct neighbor",
  "3": "Canadian indirect neighbor",
  "4": "Foreign direct neighbor",
  "5": "Foreign indirect neighbor"
};

const renderName = (data, type, row, meta) => type === 'display' ? entityLink(row) : data;

const renderStrata = (data, type, row, meta) => type === 'display' ? strataMap[data.toString()] : data;

const columns = [
  { "data": "name", "title": "Name", "render": renderName },
  { "data": "strata", "title": "Strata", "render": renderStrata, "searchable": false }
];

const initializeDatatable = () => {
  $('#cmp-strata').dataTable({
    "data": cmp_entities,
    "columns": columns
  });
};

/* <EntityTagSearch tag="cmp" />, */

const initializeEntityTagSearch = () => {
  ReactDOM.render(
    <EntitySearch />,
    document.getElementById('cmp-tag-search')
  );

}

const main = () => {
  initializeDatatable();
  initializeEntityTagSearch();
};

document.addEventListener("DOMContentLoaded", main);
