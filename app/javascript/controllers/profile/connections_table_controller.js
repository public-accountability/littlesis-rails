import { Controller } from "@hotwired/stimulus"

const CATEGORY_ICONS = new Map()
CATEGORY_ICONS.set(1, '🕴')  // position
CATEGORY_ICONS.set(2, '🎓')  // education
CATEGORY_ICONS.set(3, '🤝')  // membership
CATEGORY_ICONS.set(4, '👪')  // family
CATEGORY_ICONS.set(5, '💸')  // donation
CATEGORY_ICONS.set(6, '🧾')  // transaction
CATEGORY_ICONS.set(7, '🏢')  // lobbying
CATEGORY_ICONS.set(8, '🍻')  // social
CATEGORY_ICONS.set(9, '💼')  // professional
CATEGORY_ICONS.set(10, '👑') // ownership
CATEGORY_ICONS.set(11, '🛗') //hierarchy
CATEGORY_ICONS.set(12, '🏷') //generic

function miniumAmountFilter(settings, searchData, index, rowData) {
  const minAmount = Number(document.getElementById('connections-table-minimum-amount-filter').value)

  if (minAmount > 0) {
    return rowData.amount >= minAmount
  } else {
    return true
  }
}

function isCurrentIsBoardFilter(settings, searchData,index, rowData) {
  var state = true

  if (document.getElementById('connections-table-is-board-filter').checked) {
    if (!rowData.is_board) {
      state = false
    }
  }

  if (document.getElementById('connections-table-is-current-filter').checked) {
    if (!rowData.is_current) {
      state = false
    }
  }

  return state
}

function categoryFilter(settings, searchData, index, rowData) {
  const selection = document.getElementById('connections-table-category-filter').value
  return selection ? (rowData.category_id === Number(selection)) : true
}

function extensionsFilter(settings, searchData, index, rowData) {
  const selection = document.getElementById('connections-table-extensions-filter').value

  if (selection) {
    return rowData.other_entity.extension_definition_ids.includes(Number(selection))
  } else {
    return true
  }
}

function otherEntityRenderer(data, type, row, meta) {
  if (type === 'display') {
    let link = document.createElement('a')
    link.href = data.url
    link.target = '_blank'
    link.textContent = data.name
    link.title = data.blurb
    return link.outerHTML
  } else {
    return data.name
  }
}

function relationshipRenderer(data, type) {
  if (type === 'display') {
    let link = document.createElement('a')
    link.href = data.url
    link.target = '_blank'
    link.textContent = CATEGORY_ICONS.get(data.category_id) + ' ' + data.label
    return link.outerHTML
  } else if (type === 'filter') {
    return data.label
  } else {
    return data.id
  }
}

export default class extends Controller {
  static targets = ['json', 'table']

  initialize() {
    this.tableData = JSON.parse(this.jsonTarget.textContent)
    $.fn.dataTable.ext.search.push(miniumAmountFilter)
    $.fn.dataTable.ext.search.push(isCurrentIsBoardFilter)
    $.fn.dataTable.ext.search.push(categoryFilter)
    $.fn.dataTable.ext.search.push(extensionsFilter)

    $(this.tableTarget).DataTable({
      data: this.tableData,
      columns: [
        { name: 'other_entity', title: 'Connected To', data: 'other_entity', render: otherEntityRenderer },
        { name: 'relationship', title: 'Relationship', data: null, render: relationshipRenderer, orderable: false },
        { name: 'date', title: 'Date', data: 'date_range', orderable: false, searchable: false }
      ]
    })
  }

  redraw() {
    $(this.tableTarget).DataTable().draw()
  }
}
