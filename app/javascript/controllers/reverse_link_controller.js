import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  onClick(e) {
    e.preventDefault()

    fetch(this.urlValue, {
      "method": 'POST',
      "headers": {
        'Accept': 'application/json',
        "X-CSRF-Token": document.getElementsByName('csrf-token')[0].content
      }
    })
      .then(r => r.json())
      .then(json => {
        if (json.status == 'ok') {
          window.location.reload()
        } else {
          throw "invalid json response"
        }
      })
      .catch(console.error)

  }
}
