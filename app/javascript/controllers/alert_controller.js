import { Controller } from 'stimulus'
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = [ 'alert', 'dismisser' ] 

  dismiss(event) {
    const alertElement = this.alertTarget

    Rails.ajax({
      type: "post",
      url: this.dismisserTarget.dataset['dismissUrl'],
      data: 'id=' + this.dismisserTarget.dataset['dismissId'],
      success: function() {
        alertElement.style.display = 'none'
      }
    })
  }
}
