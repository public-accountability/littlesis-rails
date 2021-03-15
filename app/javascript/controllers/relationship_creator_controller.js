import { Controller } from 'stimulus'
import RelationshipCreationFlow from 'packs/components/relationship_creation_flow'

export default class extends Controller {
  connect() {
    let flow = new RelationshipCreationFlow()
    flow.init()
  }
}
