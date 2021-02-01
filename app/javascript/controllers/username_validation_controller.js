import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.init()
  }

  init(event) {
    Parsley.addValidator('username', {
      validateString: function(value) {
        let xhr = $.post('/users/check_username', {username: value})

        return xhr.then(function(json) {
          if (!json.valid) {
              return $.Deferred().reject('Username is taken. Please pick a new username.')
          }
        })
      } 
    })
  }
}
