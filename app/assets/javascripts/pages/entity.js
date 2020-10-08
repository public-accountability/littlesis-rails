var entity = {}

// Toggles visibility of entity summary
entity.summaryToggle = function(){
  $('.summary-excerpt').toggle()
  $('.summary-full').toggle()
  $('.summary-show-more').toggle()
  $('.summary-show-less').toggle()
}

// Toggles visibility of a related entity's additional relationships on a profile page
entity.relationshipsToggle = function(e) {
  $(e.target).closest('.relationship-section').find('.collapse').collapse('toggle')
}

/* Editable blurb */

entity._submitBlurb = function(newBlurb, original) {
  if (newBlurb !== original) {
    api.addBlurbToEntity(newBlurb, utility.entityInfo('entityid'))
  }

  $('#entity-blurb-text').html(newBlurb)
  $('#entity-blurb-pencil').show()
}

entity._editableBlurbInput = function(text) {
  function handleKeyup(e) {
    if ((e.keyCode || e.which) === 13) {
      entity._submitBlurb($(this).val(), text)
    } else if ( (e.keyCode || e.which) === 27) {
      $('#entity-blurb-text').html(text)
      $('#entity-blurb-pencil').show()
    }
  }

  return $('<input>', { "val": text, "keyup": handleKeyup })

}


entity.editableBlurb = function() {
  $("#editable-blurb").hover(
    function() {
      $("#entity-blurb-pencil").show()
    },
    function() {
      $("#entity-blurb-pencil").hide()
    }
  )
  $('#entity-blurb-pencil').click(function(){
    $(this).hide()

    // get existing blurb text
    var blurb = $('#entity-blurb-text').text() || ''

    // replace current text with input
    $('#entity-blurb-text').html(
      entity._editableBlurbInput(blurb)
    )
  })
}

// Validates an entity form via an AJAX call
entity.validate = function(form, attributes){
  entity.form = form
  $.post("/entities/validate", entity.form.serialize(), function(errors) {
    entity.errors = errors
    entity.displayErrors(attributes)
  })
}

// Display any validation errors in the entity form
entity.displayErrors = function(attributes){
  entity.form.find("#error_explanation").remove()
  var template = $(document.importNode(document.getElementById("validation_errors").content, true))
  var displayableErrors = false

  for (var i in attributes) {
    var attribute = attributes[i]

    for (var value in entity.errors[attribute]){
      if (entity.errors[attribute].hasOwnProperty(value)){
        template.find("ul").append(
          "<li>" + "<b>" + attribute + ":</b> " + entity.errors[attribute][value] + "</li>"
        )
        displayableErrors = true
      }
    }
  }

  if (displayableErrors) {
    entity.form.prepend(template)
  }
}

$(document).ready(function() {
  $('.lists-dropdown').select2({
    placeholder: 'Search for a list',
    ajax: {
      url: '/lists?editable=true',
      dataType: 'json'
    }
  });
})
