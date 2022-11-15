import "bootstrap"

import Parsley from "parsleyjs/src/parsley"
window.Parsley = Parsley

import "datatables.net"

import select2 from "select2"
select2($)

import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false

import "./controllers"
// import "./channels"
