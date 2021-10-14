/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// needed for bootstrap function like $(..).modal() to work
// see https://gorails.com/forum/how-to-use-bootstrap-with-webpack-rails-discussion
import jQuery from 'jquery';
window.$ = window.jQuery = jQuery;

import 'bootstrap'
import 'trix'
import '@rails/actiontext'
import 'parsleyjs'  // JS form validation

import "controllers"
