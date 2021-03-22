import { Controller } from 'stimulus'
import RelationshipBulkAdder from 'packs/components/relationship_bulk_adder'

export default class extends Controller {
  static values = { userIsBulker: Boolean }

  connect() {
    RelationshipBulkAdder().init(this.userIsBulkerValue)
  }
}
