import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.entityId = this.element.dataset.entityId
    this.lastPage = null
    this.currentPage = 1
    this.onArrowClick('left')
  }

  leftArrow() {
    this.onArrowClick('left')
  }

  rightArrow() {
    this.onArrowClick('right')
  }

  onArrowClick(arrowSide) {
    if (arrowSide === 'right') {
      this.currentPage += 1
    } else if (arrowSide === 'left' && this.currentPage > 1) {
      this.currentPage -= 1
    }

    this.fetchReferences(this.currentPage)
      .done((refs) => {
        if (refs.length < 10) { // then this is the last page
          this.lastPage = this.currentPage
        }
        this.updateView(refs)
      })
      .fail(() => console.error('failed to fetch more references'))
  }


  fetchReferences(page) {
    return $.getJSON("/references/entity", { "entity_id": this.entityId, "page": page })
  }

  updateView(refs) {
    $('#source-links-right-arrow').removeClass('invisible')
    $('#source-links-left-arrow').removeClass('invisible')

    if (this.currentPage === 1) {
      $('#source-links-left-arrow').addClass('invisible')
    }

    if (this.lastPage && this.lastPage === this.currentPage) {
      $('#source-links-right-arrow').addClass('invisible')
    }

    $('#source-links-container').empty()

    refs.forEach((ref) => $('#source-links-container').append(this.refToHtml(ref)))
  }

  refToHtml(ref) {
    let name = (ref.name && ref.name.length > 0) ? ref.name : ref.url
    let displayName = (name.length > 40) ? (name.substring(0,37) + '...') : name

    return $('<li>').append(
      $('<a>', {
        href: ref.url,
        text: displayName,
        target: '_blank'
      }))
  }


}
