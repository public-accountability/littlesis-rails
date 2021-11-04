import { Controller } from "@hotwired/stimulus"

const controlsHTML = `
<div class="d-flex">
  <div>
    <label>hide matched</label>
  </div>
  <div>
    <i class="bi bi-toggle-off" data-action="click->fec--match-contributions#toggleHideMatched"></i>
  </div>
</div>
`

// Connects to data-controller="fec--contributions-table"
export default class extends Controller {
  initialize() {
    // This adds a filter, that when the hide matched toggle is enabled,
    // removes any row that is already matched
    $.fn.dataTable.ext.search.push( (settings, data, rowIndex, row) => {
      if ($('.fec-controls i').hasClass('bi-toggle-on')) {
        return !row[8].includes('fec-view-relationship')
      } else {
        return true
      }
   })

    $(this.element).DataTable({
      "dom": '<"fec-header"<"fec-controls">f>ti<l>p',
      "pageLength": 25
    })

    $('.fec-header > .fec-controls').html(controlsHTML)
  }
}
