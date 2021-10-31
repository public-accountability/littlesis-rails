import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    Parsley.addValidator('username', {
      validateString: function(value) {
        return $.ajax({
          "url":  '/users/check_username',
          "method": 'POST',
          "data": { "username": value },
          "headers": {
            "X-CSRF-Token": document.getElementsByName('csrf-token')[0].content
          },
          "datatype": 'json'
        }).then(function(json) {
          if (!json.valid) {
            return $.Deferred().reject('Username is taken or invalid. Please pick a new username.')
          }
        })
      }
    })
  }
}
