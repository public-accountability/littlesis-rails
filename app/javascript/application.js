import jQuery from 'jquery'
window.$ = jQuery
window.jQuery = jQuery

import "bootstrap"
import 'parsleyjs'

import dt from 'datatables.net'
import select2 from 'select2'
select2($)
dt(window, jQuery)

import "./controllers"
