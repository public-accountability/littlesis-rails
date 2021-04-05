import { Controller } from 'stimulus'
import RelationshipsDatatable from 'packs/components/relationships_datatable'

export default class extends Controller {
  static values = { entityId: Number }

  initialize() {
    RelationshipsDatatable().start(this.entityIdValue)
  }
}
