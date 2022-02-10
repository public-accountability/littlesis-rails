import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['table']

  initialize() {
    $.fn.dataTable.ext.search.push(function(settings, searchData, index, rowData, counter) {
      let minAmount = Number(document.getElementById('connections-table-minimum-amount-filter').value)
      if (minAmount > 0) {
        return Number(rowData[4]) > minAmount
      } else {
        return true
      }
    })

    $(this.tableTarget).DataTable()
  }

  changeCategory(event) {
    const categoryId = event.target.value

    if (categoryId) {
      this.api().column('category:name').search(`category-id-${categoryId}`).draw()
    } else {
      this.api().column('category:name').search('').draw()
    }
  }

  redraw() {
    this.api().draw()
  }

  api () {
    return $(this.tableTarget).DataTable()
  }
}
