import { Controller } from 'stimulus'
import nysSearch from 'packs/components/nys_search'

export default class extends Controller {
  connect() {
    nysSearch().filerSearch()
  }
}
