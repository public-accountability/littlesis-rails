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
