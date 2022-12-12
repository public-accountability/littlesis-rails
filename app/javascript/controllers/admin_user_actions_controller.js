import { Controller } from "@hotwired/stimulus"
import { post } from "../src/common/http.mjs"

const HTML = {
  loading:
    '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>',
  success: '<i class="bi bi-check"></i>',
  error: '<i class="bi bi-emoji-frown"></i>',
}

const action = (url, target) => {
  if (!window.confirm("are you sure?")) {
    return
  }

  target.innerHTML = HTML.loading

  post(url)
    .then(json => {
      console.debug(json)
      target.innerHTML = HTML.success
    })
    .catch(err => {
      console.error(err)
      target.innerHTML = HTML.error
    })
}

export default class extends Controller {
  static values = { userid: String }

  resendConfirmationEmail(event) {
    action(`/admin/users/${this.useridValue}/resend_confirmation_email`, event.currentTarget)
  }

  resetPassword(event) {
    action(`/admin/users/${this.useridValue}/reset_password`, event.currentTarget)
  }

  deleteUser(event) {
    action(`/admin/users/${this.useridValue}/delete_user`, event.currentTarget)
  }
}
