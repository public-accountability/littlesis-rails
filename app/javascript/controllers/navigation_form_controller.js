import { Controller } from "@hotwired/stimulus"

/*
 * Where params from a form are used for navigational purposes,
 * this enables us to trigger form submits from things like
 * dropdown selection changes; since this makes submit buttons
 * redundant, we can also hide them here.
 */
export default class extends Controller {
  static targets = [ 'form', 'hideableSubmit' ]

  connect(){
    hideElement(this.hideableSubmitTarget)
  }

  submit() {
    this.formTarget.submit()
  }
}

function hideElement(e){
  e.classList.add('d-none')
}
