import { Controller } from "@hotwired/stimulus"
import mustache from 'mustache'

export default class extends Controller {
  static targets = [ 'table', 'mergeButton' ]
  static values = { possibleMerges: Array, path: String }

  initialize() {
    const possibleMerges = this.possibleMergesValue
    const path = this.pathValue
    const mergeButton = $(this.mergeButtonTarget).html()

    const selectButton = function(data) {
      return mustache.render(mergeButton, {path: `${path}&${$.param({dest: data })}`})
    }

    $(this.tableTarget).DataTable( {
      searching: false,
      lengthChange: false,
      pageLength: 15,
      order: [],
      data: possibleMerges,
      columns: [
        { title: "Name", render: renderName },
        { title: "Description" , data: 'blurb', orderable: false },
        { title: "Types", data: 'types', orderable: false },
        { title: "Select", data: 'id', orderable: false, render: selectButton }
      ]
    })
  }
}

const renderName = function(data, type, row) {
  return $('<a>', { href: row.slug, text: row.name, target: '_blank' }).prop('outerHTML')
}
