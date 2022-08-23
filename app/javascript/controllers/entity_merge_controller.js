import { Controller } from "@hotwired/stimulus"
import { get } from '../src/common/http.mjs'

const renderMergeButton = function(params) {
  const path = `/entities/merge?${$.param(params)}`
  return `<a href="${path}" class="btn btn-secondary">merge</a>`
}

const renderName = (_data, _type, row) => {
  return $('<a>', { href: row.slug, text: row.name, target: '_blank' }).prop('outerHTML')
}

export default class extends Controller {
  static values = {
    source: Number,
    mode: String,
    query: String
  }

  initialize() {
    get('/entities/merge', { "source": this.sourceValue,
                             "mode": "search",
                             "query": this.queryValue })
      .then(data => {
        $(this.element).DataTable({
          searching: false,
          lengthChange: false,
          pageLength: 15,
          order: [],
          data: data,
          columns: [
            { title: "Name", render: renderName },
            { title: "Description", data: 'blurb', orderable: false },
            { title: "Types", data: 'types', orderable: false },
            {
              title: "Select",
              data: 'id',
              orderable: false,
              render: (_data, _type, row) => renderMergeButton({
                mode: this.modeValue,
                source: this.sourceValue,
                dest: row.id
              })
            }
          ]
        })

      })
  }
}
