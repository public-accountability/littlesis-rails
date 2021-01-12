import 'select2'
import utility from '../common/utility'

function EditableBlurb() {
  const $ = window.$

  function addBlurbToEntity(blurb, entityId) {
    return fetch(`/entities/${entityId}`, {
      headers: {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
        'X-CSRF-Token': $("meta[name='csrf-token']").attr("content") || ""
      },
      method: 'POST',
      credentials: 'include',
      body: JSON.stringify({
        "entity": { "blurb": blurb },
        "reference": { "just_cleaning_up": 1 }
      })
    })
  }

  function submitBlurb(newBlurb, original) {
    if (newBlurb !== original) {
      addBlurbToEntity(newBlurb, utility.entityInfo('entityid'))
    }

    $('#entity-blurb-text').html(newBlurb)
    $('#entity-blurb-pencil').show()
  }

  function editableBlurbInput(text) {
    function handleKeyup(e) {
      if ((e.keyCode || e.which) === 13) {
        submitBlurb($(this).val(), text)
      } else if ( (e.keyCode || e.which) === 27) {
        $('#entity-blurb-text').html(text)
        $('#entity-blurb-pencil').show()
      }
    }

    return $('<input>', { "val": text, "keyup": handleKeyup })
  }

  $("#editable-blurb").hover(
    () => $("#entity-blurb-pencil").show(),
    () => $("#entity-blurb-pencil").hide()
  )

  $('#entity-blurb-pencil').click(function() {
    $(this).hide()

    // get existing blurb text
    var blurb = $('#entity-blurb-text').text() || ''

    // replace current text with input
    $('#entity-blurb-text').html(
      editableBlurbInput(blurb)
    )
  })
}

function SummaryToggle() {
  // Toggles visibility of entity summary
  $('.summary-show-more, .summary-show-less').on('click', function(){
    $('.summary-excerpt').toggle()
    $('.summary-full').toggle()
    $('.summary-show-more').toggle()
    $('.summary-show-less').toggle()
  })

  // Toggles visibility of a related entity's additional relationships on a profile page
  $('.related_entity_relationship .toggle').on('click', function(event){
    $(event.target).closest('.relationship-section').find('.collapse').collapse('toggle')
  })
}



function SearchableLists() {
  $('.lists-dropdown').select2({
    placeholder: 'Search for a list',
    ajax: {
      url: '/lists?editable=true',
      dataType: 'json'
    }
  })
}


export default class EntityPage {
  static start() {
    EditableBlurb()
    SummaryToggle()
    SearchableLists()
  }
}
