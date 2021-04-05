import { Controller } from 'stimulus'

export default class extends Controller {
  static values = { config: Object }

  connect() {
    new Oligrapher(this.configValue)
  }
}
