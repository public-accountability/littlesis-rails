import { Controller } from "@hotwired/stimulus"
import Trix from 'trix'
import '@rails/actiontext'

// Add h2 and h3 handling
Trix.config.blockAttributes.heading2 = {
  tagName: 'h2'
}
Trix.config.blockAttributes.heading3 = {
  tagName: 'h3'
}

export default class extends Controller {
  connect() {
    const heading1 = document.getElementsByClassName('trix-button--icon-heading-1')[0]

    // Add h2 and h3 buttons to the toolbar, using the h1 button as a template
    let heading2 = heading1.cloneNode(true)
    heading2.className = heading2.className.replace('heading-1', 'heading-2')
    heading2.title = "Heading 2"
    heading2.dataset['trixAttribute'] = 'heading2'

    let heading3 = heading1.cloneNode(true)
    heading3.className = heading3.className.replace('heading-1', 'heading-3')
    heading3.title = "Heading 3"
    heading3.dataset['trixAttribute'] = 'heading3'

    heading1.insertAdjacentElement('afterend', heading3)
    heading1.insertAdjacentElement('afterend', heading2)
  }
}
