import { Controller } from "@hotwired/stimulus"
import { isOverflowing } from '../../src/common/utility.mjs'

export default class extends Controller {
  connect() {
    if (!isOverflowing(this.element.querySelector('p'))) {
      this.element.querySelector('a[role="button"]').style.visibility = 'hidden'
    }
  }
}
