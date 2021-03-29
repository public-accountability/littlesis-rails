import { Controller } from 'stimulus'
import { Oligrapher } from '@publicaccountability/oligrapher'

export default class extends Controller {
  static values = { config: Object }

  connect() {
    new Oligrapher(config)
  }
}
