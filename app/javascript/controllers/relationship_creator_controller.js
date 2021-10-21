import { Controller } from "@hotwired/stimulus"
import RelationshipCreationFlow from '../src/components/relationship_creation_flow'

export default class extends Controller {
  connect() {
    let flow = new RelationshipCreationFlow()
    flow.init()
  }
}
