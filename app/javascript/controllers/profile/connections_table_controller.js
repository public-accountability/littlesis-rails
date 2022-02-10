import { Controller } from "@hotwired/stimulus"


// columns
// 4 - amount
// 5 - is_board
// 6 - is_current
function miniumAmountFilter (settings, searchData, index, rowData, counter) {
  let minAmount = Number(document.getElementById('connections-table-minimum-amount-filter').value)

  if (minAmount > 0) {
    return Number(searchData[4]) > minAmount
  } else {
    return true
  }
}

function isCurrentIsBoardFilter(_, searchData) {
  var state = true

  if (document.getElementById('connections-table-is-board-filter').checked) {
    if (searchData[5] !== 'is-board-true') {
      state = false
    }
  }

  if (document.getElementById('connections-table-is-current-filter').checked) {
    if (searchData[6] !== 'is-current-true') {
      state = false
    }
  }

  return state
}

export default class extends Controller {
  static targets = ['table']

  initialize() {
    $.fn.dataTable.ext.search.push(miniumAmountFilter)
    $.fn.dataTable.ext.search.push(isCurrentIsBoardFilter)
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
