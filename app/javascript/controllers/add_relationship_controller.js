import { Controller } from "@hotwired/stimulus"
import ExistingReferenceWidget from "../src/components/existing_reference_selector"
import { validURL } from "../src/common/utility.mjs"
import { get, postFetch } from "../src/common/http.mjs"

export default class extends Controller {
  static targets = ["categories", "widget", "url", "file", "name"]

  static values = {
    entity1: Number,
    entity2: Number,
  }

  initialize() {
    this.widget = null
    this.category = null
    this.error = null
  }

  widgetTargetConnected(element) {
    this.widget = new ExistingReferenceWidget(
      [this.entity1Value, this.entity2Value],
      this.referenceSelected.bind(this)
    )
  }

  fetchName() {
    if (this.widget.selection) {
      return
    } else if (this.urlTarget.value && validURL(this.urlTarget.value)) {
      get(`/title_extractor/${this.urlTarget.value}`)
        .then(json => (this.nameTarget.value = json.title))
        .catch(console.error)
    } else {
      this.urlTarget.focus()
    }
  }

  selectCategory(event) {
    this.categoriesTarget
      .querySelectorAll("button.active")
      .forEach(btn => btn.classList.remove("active"))
    event.currentTarget.classList.add("active")
    this.category = Number(event.currentTarget.dataset.category)
  }

  referenceSelected() {
    if (this.widget.selection) {
      this.nameTarget.value = this.widget.selectedDocument.name
      this.nameTarget.disabled = true
      this.urlTarget.value = this.widget.selectedDocument.url
      this.urlTarget.disabled = true
      this.fileTarget.disabled = true
    } else {
      this.nameTarget.value = ""
      this.nameTarget.disabled = false
      this.urlTarget.value = ""
      this.urlTarget.disabled = false
      this.fileTarget.disabled = false
    }
  }

  toggleFileUpload(event) {
    this.urlTarget.classList.toggle("d-none")
    this.fileTarget.classList.toggle("d-none")
    const icon = event.currentTarget.querySelector("i")
    icon.classList.toggle("bi-arrow-up")
    icon.classList.toggle("bi-link")
  }

  get params() {
    return {
      relationship: {
        category_id: this.category,
        entity1_id: this.entity1Value,
        entity2_id: this.entity2Value,
      },
      reference: {
        document_id: this.widget.selection,
        name: this.nameTarget.value,
        url: this.urlTarget.value,
      },
    }
  }

  validate() {
    const params = this.params
    const hasDocumentOrFile = params.reference.document_id || this.fileTarget.files.length > 0

    if (!params.relationship.category_id) {
      this.error = "Please select a category"
    } else if (
      !params.reference.document_id &&
      this.fileTarget.files.length > 0 &&
      this.fileTarget.files.item(0).size > 5000000
    ) {
      this.error = "File is too large"
    } else if (!hasDocumentOrFile && !params.reference.url) {
      this.error = "Missing URL"
    } else if (!hasDocumentOrFile && !validURL(params.reference.url)) {
      this.error = "Invalid URL"
    } else if (!params.reference.document_id && !params.reference.name) {
      this.error = "Missing name"
    } else {
      this.error = null
    }

    const alert = this.element.querySelector("#add-relationship-validation-error")

    if (this.error) {
      alert.classList.remove("d-none")
      alert.querySelector("span.alertText").textContent = this.error
    } else {
      alert.classList.add("d-none")
      alert.querySelector("span.alertText").textContent = ""
    }
  }

  async create() {
    this.validate()

    if (!this.error) {
      const params = this.params

      if (!params.reference.document_id || this.fileTarget.files.length > 0) {
        params.refernce.data = await this.fileTarget.files.item(0).arrayBuffer().then(encode)
      }

      return postFetch("/relationships", params)
        .then(response => response.json())
        .then(json => {
          if (json.error) {
            this.error = `server error: ${json.error}`
            const alert = this.element.querySelector("#add-relationship-validation-error")
            alert.classList.remove("d-none")
            alert.querySelector("span.alertText").textContent = this.error
          } else if (json.url) {
            window.location = json.url
          }
        })
    }
  }
}
