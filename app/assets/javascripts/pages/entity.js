var entity = {}; 

// Toggles visibility of entity summary
entity.summaryToggle = function(){
  $('.summary-excerpt').toggle();
  $('.summary-full').toggle();
  $('.summary-show-more').toggle();
  $('.summary-show-less').toggle();
};

// Toggles visibility of a related entity's additional relationships on a profile page
entity.relationshipsToggle = function(e) {
  $(e.target).closest('.relationship-section').find('.collapse').collapse('toggle');
};



/* Editable blurb */

entity._submitBlurb = function(newBlurb, original) {
  if (newBlurb !== original) {
    // do ajax
  }

  $('#entity-blurb-text').html(newBlurb);
  $('#entity-blurb-pencil').show();
};

entity._editableBlurbInput = function(text) {

  function handleKeyup(e) {
    if (e.keyCode === 13) {
      entity._submitBlurb($(this).val(), text);
    } else if (e.keyCode === 27) {
      $('#entity-blurb-text').html(text);
      $('#entity-blurb-pencil').show();
    }
  }

  return $('<input>', { "val": text, "keyup": handleKeyup });

};


// utility.entityInfo
entity.editableBlurb = function() {
  $('#entity-blurb-pencil').click(function(x){
    $(this).hide();

    // get existing blurb text
    var blurb = $('#entity-blurb-text').text() || '';

    // replace current text with input
    $('#entity-blurb-text').html(
      entity._editableBlurbInput(blurb)
    );
  });
};
