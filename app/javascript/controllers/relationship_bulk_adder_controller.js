import { Controller } from "@hotwired/stimulus"
import RelationshipBulkAdder from '../src/components/relationship_bulk_adder'

export default class extends Controller {
  static values = { userIsBulker: Boolean }

  connect() {
    RelationshipBulkAdder().init(this.userIsBulkerValue)
  }
}
