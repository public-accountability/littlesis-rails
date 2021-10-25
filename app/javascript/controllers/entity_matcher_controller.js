import { Controller } from "@hotwired/stimulus"
import EntityMatcher from '../src/components/entity_matcher'

const columns = [
  { "data": 'name', "title": 'Name', "name": 'name'},
  { "data": 'filer_id', "title": 'Filer ID', "name": 'filer_id' },
  { "data": 'id', "visible": false, "name": 'id' }
]

export default class extends Controller {
  static targets = [ 'table' ]

  connect() {
    const matcher = new EntityMatcher({
      rootElement: this.tableTarget,
      columns: columns,
      endpoint: '/nys/datatable',
      matchUrl: '/nys/ny_filer_entity'
    })

    matcher.init()
  }
}
