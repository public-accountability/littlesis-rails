import { Controller } from 'stimulus'

export default class extends Controller {
  static values = { config: Object }

  connect() {
    window.Oligrapher.instance = new Oligrapher(this.configValue)
  }
}
