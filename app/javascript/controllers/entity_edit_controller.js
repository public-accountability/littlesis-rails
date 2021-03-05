import { Controller } from 'stimulus'

export default class extends Controller {

  connect(){
    $('#entity_regions').select2()
  }

  checkType(event) {
    $(event.target).toggleClass(['glyphicon-check', 'glyphicon-unchecked'])

    // Stores checked type boxes (entity extention definition ids) in a hidden field
    $(event.target)
      .map(function() { return event.target.dataset.definitionId })
      .toArray()
      .join(',')
  }
}
