import { Controller } from 'stimulus'
import DonationMatcher from 'packs/components/donation_matcher'

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
