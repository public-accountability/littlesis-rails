import { Controller } from "@hotwired/stimulus"
import { post } from '../src/common/http.mjs'

export default class extends Controller {
  static targets = [ 'table', 'preview']

  tableTargetConnected(target) {
    $('#oligrapher-search-results-table').DataTable({
      "ordering": false,
      "info": false,
      "searching": false,
      "lengthChange": false
    })
  }

  previewTargetConnected(target) {
    let url = target.dataset.screenshoturl

    $(target)
      .popover({
        html: true,
        trigger: 'hover',
        template: '<div class="popover" role="tooltip"><div class="popover-body"></div></div>',
        content: `<img src="${url}" class="img-responsive w-100">`
      })
  }

  toggleIsFeatured(event) {
    post(event.target.dataset.url, {}).then(() => {
      event.target.querySelector('span').classList.toggle('star')
      event.target.querySelector('span').classList.toggle('not-star')
    })
      .catch(console.error)
  }
}
