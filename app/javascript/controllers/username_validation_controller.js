import { Controller } from "@hotwired/stimulus"
import { post } from '../src/common/http.mjs'

const errorMsg = 'Username is taken or invalid. Please pick a new username.'

export default class extends Controller {
  initialize() {
    Parsley.addValidator('username', {
      validateString: function(value) {
        return post('/users/check_username', { "username": value })
          .then(res => {
            if (!res.valid) {
              throw errorMsg
            }
          })
      }
    })
  }
}
