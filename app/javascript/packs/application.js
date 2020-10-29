/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import utility from './common/utility';
import http from './common/http';
import clipboardjs from 'clipboard';
import datatable from 'datatables.net';
import typeahead from 'typeahead.js';
import mustache from 'mustache';

import listDatatableLoader from './list_datatable';
import entityAutocomplete from './entity_autocomplete';
import RelationshipCreationFlow from './components/relationship_creation_flow'

window.utility = utility;
window.utility.delete = utility.del;
window.clipboardjs = clipboardjs;
window.datatable = datatable;
window.mustache = mustache;

if (!window.LittleSis) {
  window.LittleSis = {};
}

$.typeahead = typeahead;

window.LittleSis.http = http;
window.LittleSis.listDatatableLoader = listDatatableLoader;
window.LittleSis.entityAutocomplete = entityAutocomplete;
window.LittleSis.RelationshipCreationFlow = RelationshipCreationFlow;
