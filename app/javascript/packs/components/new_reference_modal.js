$(document).ready(function(){

  $('#reference-form').submit(function(event){
    if (this.checkValidity()) {
      // only prevent the default action and submit using ajax
      // if the form is valid. If it's not, then the browser will
      // not submit the form instead show validations
      event.preventDefault()
      var statusCode =  {
        201: function() {
          location.reload() // reload the page
        },
        400: function(jqXHR) {
          // Display an alert showing the ActiveModel
          var errors = jqXHR.responseJSON.errors
          var html = Object.keys(errors).map(function(key){
            return "<p><strong>" + key + ":  </strong>" + errors[key] + "</p>"
          }).join()
          $('#reference-errors').html(html)
          $('#reference-error-alert').show()
          
          $('#reference-loading').hide()
          $('form').show()
          $('.modal-footer').show()
        }
      }

      $.ajax({
        type: 'POST',
        url: '/references',
        data: $('#reference-form').serialize(),
        statusCode: statusCode
      })
      $('#reference-loading').show()
      $('form').hide()
      $('.modal-footer').hide()
    }
  })

})
