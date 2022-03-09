import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['icon']

  toggle() {
    this.iconTarget.classList.toggle('bi-plus-circle')
    this.iconTarget.classList.toggle('bi-dash-circle')
  }
}
