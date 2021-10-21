import { Controller } from "@hotwired/stimulus"
import DonationMatcher from '../src/components/donation_matcher'

export default class extends Controller {
  static values = { mode: String }

  connect() {
    const matcher = DonationMatcher()

    if ( this.modeValue === 'review' ) {
      matcher.unmatch_init()
    } else {
      matcher.init()
    }
  }
}
