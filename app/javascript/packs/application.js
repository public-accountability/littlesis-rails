/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import jquery from 'jquery'
import Rails from "@rails/ujs"
import 'bootstrap'
import 'bootstrap-select'
import 'jquery-typeahead'

import 'd3'
import 'papaparse'
import 'file-saver'
import 'select2'

// JS form validation
import 'parsleyjs'

import utility from './common/utility'
import http from './common/http'
import datatable from 'datatables.net'
import typeahead from 'typeahead.js'
import mustache from 'mustache'

import nysSearch from './components/nys_search'
import EntityMatcher from './components/entity_matcher'

jquery.typeahead = typeahead
window.$ = jquery
window.jQuery = jquery
window.utility = utility
window.utility.delete = utility.del
window.datatable = datatable
window.mustache = mustache

if (!window.LittleSis) {
  window.LittleSis = {}
}

window.LittleSis.http = http
window.LittleSis.nysSearch = nysSearch
window.LittleSis.EntityMatcher = EntityMatcher

import "controllers"
Rails.start()
