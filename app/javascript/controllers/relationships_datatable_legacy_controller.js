import { Controller } from "@hotwired/stimulus"
import RelationshipsDatatable from '../src/components/relationships_datatable'

export default class extends Controller {
  static values = { entityId: Number }

  initialize() {
    RelationshipsDatatable().start(this.entityIdValue)
  }
}
