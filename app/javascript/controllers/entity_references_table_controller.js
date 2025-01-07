import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['table']
  static values = {
    entityid: Number,
    signedin: Boolean
  }

  initialize() {
    const url = `/references/documents?data[referenceable_type]=Entity&data[referenceable_id]=${this.entityidValue}`
    const userSignedIn = this.signedinValue

    $(this.tableTarget).DataTable({
      ajax: {
        url: url,
        dataSrc: ''
      },
      columns: [
        {
          data: "name",
          orderable: false,
          title: 'Document',
          render: function(data, type, row) {
            if (type === 'display') {
              let html = `<a target="_blank" href="${row.url}" title="${row.url}">${row.name}</a>`

              if (userSignedIn) {
                let turboFrameId = `documents_edit_${row.id}`
                html += `<turbo-frame id="${turboFrameId}"><a href="/documents/${row.id}/edit_document" class="ms-2"><i class="bi bi-pencil-square hvr-pop ml-1"></i></a></turbo-frame>`
              }

              return html
            } else {
              return data
            }
          }
        },
        {
          data: "updated_at",
          searchable: false,
          title: 'Updated',
          render: function(data, type, row) {
            return type === 'display' ? data.slice(0,10) : data
          }
        }
      ],
      order: [[1, 'desc']]

    })
  }

}
