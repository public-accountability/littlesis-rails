/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Rails from "@rails/ujs"
import 'bootstrap'
import 'bootstrap-select'

import 'd3'

// JS form validation
import 'parsleyjs'

import nysSearch from './components/nys_search'
import EntityMatcher from './components/entity_matcher'

if (!window.LittleSis) {
  window.LittleSis = {}
}

window.LittleSis.nysSearch = nysSearch
window.LittleSis.EntityMatcher = EntityMatcher

import "controllers"
Rails.start()
