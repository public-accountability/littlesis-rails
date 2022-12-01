import { Controller } from "@hotwired/stimulus"
import ExistingReferenceWidget from "../src/components/existing_reference_selector"
import { validURL } from "../src/common/utility.mjs"
import { get } from "../src/common/http.mjs"

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

  validate() {
    const hasDocumentOrFile = this.widget.selection || this.fileTarget.files.length > 0

    if (!this.category) {
      this.error = "Please select a category"
    } else if (
      (!this.widget.selection,
      this.fileTarget.files.length > 0 && this.fileTarget.files.item(0).size > 5000000)
    ) {
      this.error = "File is too large"
    } else if (!hasDocumentOrFile && !this.urlTarget.value) {
      this.error = "Missing URL"
    } else if (!hasDocumentOrFile && !validURL(this.urlTarget.value)) {
      this.error = "Invalid URL"
    } else if (!this.widget.selection && !this.nameTarget.value) {
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

  formData() {
    const formData = new FormData()
    formData.set("relationship[category_id]", this.category)
    formData.set("relationship[entity1_id]", this.entity1Value)
    formData.set("relationship[entity2_id]", this.entity2Value)

    if (this.widget.selection) {
      formData.set("reference[document_id]", this.widget.selection)
    } else if (this.fileTarget.files.length > 0) {
      formData.set("reference[primary_source_document]", this.fileTarget.files[0])
      formData.set("reference[name]", this.nameTarget.value)
    } else {
      formData.set("reference[name]", this.nameTarget.value)
      formData.set("reference[url]", this.urlTarget.value)
    }

    return formData
  }

  create() {
    this.validate()

    if (this.error) {
      console.error(this.error)
      return
    }

    const options = {
      headers: {
        "X-CSRF-Token": document.head.querySelector('meta[name="csrf-token"]').content,
        Accept: "application/json",
      },
      method: "POST",
      body: this.formData(),
    }

    return fetch("/relationships", options)
      .then(response => {
        if (response.status === 500) {
          throw new Error("HTTP STATUS 500")
        } else {
          return response.json()
        }
      })
      .then(json => {
        if (json.error) {
          this.error = `server error: ${json.error}`
          const alert = this.element.querySelector("#add-relationship-validation-error")
          alert.classList.remove("d-none")
          alert.querySelector("span.alertText").textContent = this.error
        } else if (json.url) {
          window.location = json.url
        } else {
          throw new Error(`cannot handle response: ${JSON.stringify(json)}`)
        }
      })
      .catch(console.error)
  }
}
