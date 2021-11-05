import { Controller } from "@hotwired/stimulus"

const controlsHTML = `
<div class="d-flex">
  <div>
    <label>include hidden</label>
    <i class="bi bi-toggle-off include-hidden-toggle" data-action="click->fec--match-contributions#toggleIncludeHidden"></i>
  </div>
  <div>
    <label>hide matched</label>
    <i class="bi bi-toggle-off hide-matched-toggle" data-action="click->fec--match-contributions#toggleHideMatched"></i>
  </div>
</div>
`

// Connects to data-controller="fec--contributions-table"
export default class extends Controller {
  initialize() {
    // This adds a filter, that when the hide matched toggle is enabled,
    // removes any row that is already matched
    $.fn.dataTable.ext.search.push( (settings, data, rowIndex, row) => {
      let rowIsMatched = Boolean($('#fec-contributions-table').DataTable().row(rowIndex).node().querySelector('td:nth-child(9) i.fec-view-relationship'))
      let rowIsHidden = Boolean($('#fec-contributions-table').DataTable().row(rowIndex).node().querySelector('td:nth-child(9) i.fec-show-contribution'))
      let hideMatchedIsToggled = $('.fec-controls i.hide-matched-toggle').hasClass('bi-toggle-on')
      let includeHiddenToggled = $('.fec-controls i.include-hidden-toggle').hasClass('bi-toggle-on')

      if (hideMatchedIsToggled && rowIsMatched) {
        return false
      }

      if (includeHiddenToggled) {
        return true
      } else {
        return !rowIsHidden
      }
    })

    // re-render Datatable after turbo-frame is rendered
    document.documentElement.addEventListener("turbo:frame-render", function() {
      $('#fec-contributions-table').DataTable().draw()
    })

    // Initialize Datatables
    $(this.element).DataTable({
      "dom": '<"fec-header"f<"fec-controls">>ti<l>p',
      "pageLength": 25
    })

    $('.fec-header > .fec-controls').html(controlsHTML)
  }
}
