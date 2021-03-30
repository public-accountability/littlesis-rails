import { Controller } from 'stimulus'

export default class extends Controller {
  static values = { data: Array, name: String }
  static targets = [ 'table' ]

  connect() {
    $(this.tableTarget).DataTable({
      data: this.dataValue,
      lengthChange: false,
      pageLength: 15,
      columns: columnConfigs[this.nameValue]
    })
  }
}

const columnConfigs = {
  lists: [
    {data: listLink, title: 'List'},
    {data: 'access', title: 'Access', searchable: false},
    {data: 'updated_at', title: 'Updated at'}
  ],
  maps: [
    {title: "Title"},
    {title: "Updated At"}
  ]
}

function listLink(data) {
  return $('<a>', {
    text: data.name,
    target: '_blank',
    href: data.href
  }).prop('outerHTML')
}
