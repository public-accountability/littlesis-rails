import { Controller } from "@hotwired/stimulus"
import { get } from '../../src/common/http.mjs'

export default class extends Controller {
  static values = {
    entityId: Number
  }

  initialize() {
    get(`/datatable/entity/${this.entityIdValue}`)
      .then(this.render)
      .catch(console.error)
  }

  render(data) {
    console.log(data)
  }

}
