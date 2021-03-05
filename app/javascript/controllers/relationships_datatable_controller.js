import { Controller } from 'stimulus'

export default class extends Controller {
  static values = { entityId: Number }

  initialize() {
    LittleSis.RelationshipsDatatable().start(this.entityIdValue)
  }
}
