import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { role: String }

  connect() {
    const currentRole = this.roleValue

    this.element.querySelector('select').addEventListener('change', function(event) {
      let selected = this.value

      if (currentRole === 'admin') {
        alert('you cannot change the role of an admin')
        this.value = currentRole
      } else if (selected === 'admin') {
        alert('you cannot use this interface to create new admins')
        this.value = currentRole
      } else {
        // http request
      }

    })
  }
}
