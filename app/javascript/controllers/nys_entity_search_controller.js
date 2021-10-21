import { Controller } from "@hotwired/stimulus"
import nysSearch from '../src/components/nys_search'

export default class extends Controller {
  static values = { primaryExt: String }

  connect() {
    nysSearch().entitySearch(this.primaryExtValue)
  }
}
