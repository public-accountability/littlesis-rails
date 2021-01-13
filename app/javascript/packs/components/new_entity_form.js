let entity = {}

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
      if (Object.prototype.hasOwnProperty.call(entity.errors[attribute], value)){
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
  $('input[type=radio]').on("change", function() {
    if (this.value == "Person") {
      $("#other-types").show()
      $("#org-types").hide()
      $("#person-types").show()
    } else if (this.value == "Org") {
      $("#other-types").show()
      $("#person-types").hide()
      $("#org-types").show()
    } else {
      $("#other-types").hide()
      $("#person-types").hide()
      $("#org-types").hide()
    }
  })

  $('#new_entity input').on("blur", function() {
    entity.validate($('#new_entity'), ["name"])
  })

  var input = $("#entity_name")
  var typingTimer
  var doneTypingInterval = 100

  //on keyup, start the countdown
  input.on('keyup', function() {
    clearTimeout(typingTimer)
    typingTimer = setTimeout(findMatches.bind(input[0]), doneTypingInterval)
  })

  //on keydown, clear the countdown
  input.on('keydown', function() {
    clearTimeout(typingTimer)
  })

  var existing = $("#existing")[0]

  var findMatches = function() {
    var query = $.trim(this.value)
    if (query.length > 2) {
      $.ajax({
        method: "GET",
        url: "/search/entity",
        data: { q: query, num: 5 }
      }).done(function(results) {
        existing.innerHTML = ""
        if (results.length > 0) {
          results.forEach(function(result) {
            var strong = document.createElement("strong")
            var em = document.createElement("em")
            var link = document.createElement("a")
            link.href = result.url
            link.innerHTML = result.name
            strong.appendChild(link)
            existing.appendChild(strong)
            if (result.blurb) {
              em.innerHTML = result.blurb
                $(existing).append(" &nbsp;")
              existing.appendChild(em)
            }
            $(existing).append("<br>")
          })
          $("#wait").show()
        } else {
          $("#wait").hide()
        }
      })
    } else {
      $("#wait").hide()
      existing.innerHTML = ""
    }
  }
})
