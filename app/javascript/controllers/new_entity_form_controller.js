import { Controller } from "@hotwired/stimulus"
import $ from 'jquery'
import trim from 'lodash/trim'
import delay from 'lodash/delay'

// Connects to data-controller="new-entity-form"
export default class extends Controller {
  static targets = ['personTypes', 'orgTypes', 'otherTypes', 'wait', 'existing', 'nameInput' ]

  // connect() {}

  selectPrimaryExt(event) {
    if (event.target.value === 'Person') {
      $(this.personTypesTarget).show()
      $(this.orgTypesTarget).hide()
      $(this.otherTypesTarget).show()
    } else if (event.target.value === 'Org') {
      $(this.personTypesTarget).hide()
      $(this.orgTypesTarget).show()
      $(this.otherTypesTarget).show()
    } else  {
      $(this.personTypesTarget).hide()
      $(this.orgTypesTarget).hide()
      $(this.otherTypesTarget).hide()
    }

    this.typingEntityName()
  }

  typingEntityName(event) {
    let entityName = this.nameInputTarget.value || ''

    if (entityName.length < 4) {
      $(this.waitTarget).hide()
      return
    }

    if (!this.element.querySelector("input[name=entity\\[primary_ext\\]]:checked")) {
      return
    }

    let selectedPrimaryExt = this.element.querySelector("input[name=entity\\[primary_ext\\]]:checked").value

    if (this.lastRequest) {
      clearInterval(this.lastRequest)
    }
    this.lastRequest = delay(() => this.findMatches(entityName, selectedPrimaryExt), 300)
  }


  findMatches(entityName, primaryExt) {
    this.lastSearch = entityName

    $.ajax({
      method: "GET",
      url: "/search/entity",
      data: { q: entityName, num: 5, ext: primaryExt }
    }).done(results => {
      if (entityName != this.lastSearch) {
        console.log("skipping out of order result")
        return
      }

      if (results.length > 0) {
        this.displayMatches(results)
      } else {
        $(this.waitTarget).hide()
      }
    })
  }

  displayMatches(results) {
    $(this.waitTarget).show()
    $(this.existingTarget).empty()

    results.forEach(result => {
      $(this.existingTarget).append(
        `
<div>
  <a href="${result.url}" target="_blank"><strong>${result.name}</strong></a>
  <em>&nbsp;${result.blurb}</em>
</div>
       `)

    })
  }

}
