import { Controller } from "@hotwired/stimulus"
import 'tinycarousel'

export default class extends Controller {
  static targets = [ 'carousel' ]

  connect() {
    $(this.carouselTarget).tinycarousel({
      pager: true,
      start: 1,
      interval: true,
      intervaltime: 5000,
      rewind: true,
      animation: true
    })
  }
}
