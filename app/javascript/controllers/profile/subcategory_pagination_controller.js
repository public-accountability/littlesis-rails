import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    page: { type: Number, default: 1 },
    totalPages: Number
  }

  static targets = ['prevLink', 'nextLink']

  connect() {
    if (this.totalPagesValue === 1) {
      return
    }

    if (this.pageValue === 1) {
      this.prevLinkTarget.classList.add('disabled')
      this.prevLinkTarget.href = '#'
    } else if (this.pageValue === this.totalPagesValue) {
      this.nextLinkTarget.classList.add('disabled')
      this.nextLinkTarget.href = '#'
    }
  }

}
