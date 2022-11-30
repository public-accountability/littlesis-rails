import { Controller } from "@hotwired/stimulus"
import ExistingReferenceWidget from "../src/components/existing_reference_selector"

export default class extends Controller {
  static targets = ["widget"]

  static values = {
    entity1: Number,
    entity2: Number,
  }

  initialize() {
    this.widget = null
  }

  widgetTargetConnected(element) {
    this.widget = new ExistingReferenceWidget([this.entity1Value, this.entity2Value])
  }
}
