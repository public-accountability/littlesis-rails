import { Controller } from "@hotwired/stimulus"

const usernameRegex = /^[A-Za-z]{1}\w{2,}$/

export default class extends Controller {
  initialize() {
    Parsley.addValidator("username", {
      validateString: function (value) {
        return (
          value.length > 2 &&
          value.length < 20 &&
          !value.toLowerCase().includes("admin") &&
          !value.toLowerCase().includes("system") &&
          !value.toLowerCase().includes("locksmith") &&
          usernameRegex.test(value)
        )
      },
    })
  }
}
