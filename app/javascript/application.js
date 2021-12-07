import jQuery from 'jquery'
window.$ = jQuery
window.jQuery = jQuery

import 'bootstrap'
import 'parsleyjs/src/parsley'

import dt from 'datatables.net'
import select2 from 'select2'
select2($)
dt(window, jQuery)


import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false

import "./controllers"
