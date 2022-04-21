import { Controller } from "@hotwired/stimulus"
import { post } from '../src/common/http.mjs'


export default class extends Controller {
  changeSubscription(event) {
    post(`/users/action_network/${event.target.checked ? 'subscribe' : 'unsubscribe'}`, {})
  }

  changeTag(event) {
    post("/users/action_network/tag", {
           tag: event.target.value,
           status: event.target.checked
    })
  }
}
