import { get } from '../common/http.mjs'

const REFERENCES_PER_PAGE = 75
const REQUEST_URL = "/references/recent"
const CONTAINER_DIV = "#reference-widget-container"

function formatDocument(document) {
  return $(
    `<span title="${document.url}">${document.name}</span>`
  )
}

export default class ExistingReferenceWidget {
  constructor(entityIds) {
    this.entityIds = [].concat(entityIds).map(Number)
    this.documents = null
    this.render = this.render.bind(this)
    this.getDocs().then(this.render)
  }

  getDocs() {
    return get(REQUEST_URL, { "entity_ids": this.entityIds,
                              "per_page": REFERENCES_PER_PAGE,
                              "exclude_type": 'fec' })
      .then(data => this.documents = data)
      .catch(() => console.error("failed to get references from /references/recent"))
  }

  render() {
    $(CONTAINER_DIV).html("<select> <option></option></select>")

    $(`${CONTAINER_DIV} > select`).select2({
      "data": this.documents.map(d => Object.assign(d, { "text": d.name })),
      "placeholder": "Select a reference",
      "allowClear": true,
      "templateResult": formatDocument
    })

  }

  get selection() {
    let value = $(`${CONTAINER_DIV} > select`).val()

    if (value) {
      return Number(value)
    } else {
      return null
    }
  }

}
