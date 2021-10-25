import { Controller } from "@hotwired/stimulus"
import $ from 'jquery'
import select2 from 'select2'
import utility from '../src/common/utility.mjs'



export default class extends Controller {
  static targets = [
    'blurbPencil',
    'blurbText',
    'summaryExcerpt',
    'summaryFull',
    'summaryMore',
    'summaryLess',
    'listsDropdown'
  ]

  connect() {
    if (this.hasListsDropdownTarget) {
      $(this.listsDropdownTarget).select2({
        placeholder: 'Search for a list',
        ajax: {
          url: '/lists?editable=true',
          dataType: 'json'
        }
      })
    }
  }

  showPencil() {
    $(this.blurbPencilTarget).show()
  }

  hidePencil() {
    $(this.blurbPencilTarget).hide()
  }

  editBlurb() {
    this.hidePencil

    let textElement = this.blurbTextTarget
    let existingText = textElement.innerHTML
    let input = $('<input>', { 'val': existingText })

    $(input).on('keyup', function(e){
      if (enterPressed(e) && textChanged(input.val())) {
        updateBlurb(input.val(), utility.entityInfo('entityid'))
        textElement.innerHTML = input.val()
      } else if (escapePressed(e)) {
        textElement.innerHTML = existingText
      }
      this.showPencil
    })

    $(this.blurbTextTarget).html(input)

    function textChanged(newText) {
      return newText !== existingText
    }
  }

  toggleSummary() {
    $(this.summaryExcerptTarget).toggle()
    $(this.summaryFullTarget).toggle()
    $(this.summaryMoreTarget).toggle()
    $(this.summaryLessTarget).toggle()
  }

  toggleRelationship(event) {
    $(event.target).closest('.relationship-section').find('.collapse').collapse('toggle')
  }
}

function escapePressed(event) {
  return (event.keyCode || event.which) === 27
}

function enterPressed(event) {
  return (event.keyCode || event.which) === 13
}

function updateBlurb(blurb, entityId) {
  return fetch(`/entities/${entityId}`, {
    headers: {
      'Accept': 'application/json, text/plain, */*',
      'Content-Type': 'application/json',
      'X-CSRF-Token': $("meta[name='csrf-token']").attr("content") || ""
    },
    method: 'PATCH',
    credentials: 'include',
    body: JSON.stringify({
      "entity": { "blurb": blurb },
      "reference": { "just_cleaning_up": 1 }
    })
  })
}
