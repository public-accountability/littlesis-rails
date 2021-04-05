import { Controller } from 'stimulus'
import nysSearch from 'packs/components/nys_search'

export default class extends Controller {
  static values = { primaryExt: String }

  connect() {
    nysSearch().entitySearch(this.primaryExtValue)
  }
}
