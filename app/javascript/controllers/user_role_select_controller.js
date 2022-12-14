import { Controller } from "@hotwired/stimulus"
import { post } from "../src/common/http.mjs"

export default class extends Controller {
  static values = { role: String, userid: Number }

  connect() {
    const currentRole = this.roleValue
    const select = this.element.querySelector("select")

    select.value = currentRole

    if (currentRole === "admin" || currentRole === "deleted") {
      select.disabled = true
      select.title = `You cannot change the role of a ${currentRole} user`
    } else {
      this.addChangeEvent(select, currentRole)
    }
  }

  addChangeEvent(element, currentRole) {
    const userid = this.useridValue

    element.addEventListener("change", function () {
      let selected = this.value

      if (selected === "admin" || selected === "system") {
        alert(`You cannot use this interface to create ${selected} users`)
        this.value = currentRole
      } else {
        element.disabled = true // loading...
        post(`/admin/users/${userid}/set_role`, { role: selected })
          .then(() => (element.disabled = false))
          .catch(err => {
            console.error(err)
            element.parentElement.innerHTML = "<em>something went wrong</em>"
          })
      }
    })
  }
}
