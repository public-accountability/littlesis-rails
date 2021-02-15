import { Controller } from 'stimulus'
import tags from 'packs/common/tags'

export default class extends Controller {
  static values = { data: Object, endpoint: String, alwaysEdit: Boolean }

  initialize() {
    if ( !$.isEmptyObject(this.dataValue) ){
      tags().init(this.dataValue, this.endpointValue, this.alwaysEditValue)
    }
  }
}
