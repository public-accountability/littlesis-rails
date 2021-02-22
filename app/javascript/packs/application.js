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
import 'tinycarousel'
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

import entityAutocomplete from './entity_autocomplete'
import RelationshipCreationFlow from './components/relationship_creation_flow'
import NyDonationsMatcher from './components/ny_donations_matcher'
import nysSearch from './components/nys_search'
import EntityMatcher from './components/entity_matcher'
import RelationshipBulkAdder from './components/relationship_bulk_adder'
import DonationMatcher from './components/donation_matcher'
import RelationshipsDatatable from './components/relationships_datatable'
import EntityPage from './components/entity_page'

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
window.LittleSis.entityAutocomplete = entityAutocomplete
window.LittleSis.RelationshipCreationFlow = RelationshipCreationFlow
window.LittleSis.NyDonationsMatcher = NyDonationsMatcher
window.LittleSis.nysSearch = nysSearch
window.LittleSis.EntityMatcher = EntityMatcher
window.LittleSis.RelationshipBulkAdder = RelationshipBulkAdder
window.LittleSis.DonationMatcher = DonationMatcher
window.LittleSis.RelationshipsDatatable = RelationshipsDatatable
window.LittleSis.EntityPage = EntityPage

import "controllers"
Rails.start()
