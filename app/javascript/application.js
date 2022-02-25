import 'bootstrap'

import Parsley from 'parsleyjs/src/parsley'
window.Parsley = Parsley

import dt from 'datatables.net'
dt(window, $)

import select2 from 'select2'
select2($)

import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false

import "./controllers"
