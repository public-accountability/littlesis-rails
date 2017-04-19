/**
 Show recent references for profile page sidebar

  selectors:
    #source-links-left-arrow
    #source-links-right-arrow
    #source-links-container  (ul)

*/
var sidebarSourceLinks = (function($){
  var entityId = null;
  var lastPage = null;
  var currentPage = 1;

  // integer -> JqueryAjaxPromiseThing
  function getRefs(page) {
    var params = { entity_id: entityId, page: page };
    return $.getJSON("/references/entity", params);
  }

  // updates currentPage after click
  function updateCurrentPage(arrowSide) {
    if (arrowSide === 'right') {
      currentPage += 1;
    } else if (arrowSide === 'left') {
      if (currentPage > 1) {
	currentPage -= 1;
      }
    } else {
      throw "arrowSide must  be 'left' or 'right'";
    }
  }

  function retriving(on) {
    if (on == true) {
      // show 'processing' 
    } else {
      // disable 'processing'
    }
  }

  // {} -> html element
  function refToHtml(ref){
    var name = (ref.name && ref.name.length > 0) ? ref.name : ref.source;
    var displayName = (name.length > 40) ? (name.substring(0,37) + '...') : name;

    return $('<li>').append(
      $('<a>', {
	href: ref.source, 
	text: displayName
      }));
  }

  // redisplays references list
  // [{}] -> 
  function displayReferences(refs) {
    $('#source-links-container').empty();
    refs.forEach(function(ref){
      $('#source-links-container')
	.append(refToHtml(ref));
    });
  }

  function hideRightArrow(){}
  function hideLeftArrow(){}
  
  function showAllArrows() {
  }

  // updates arrows and re-renders reference list
  // [{}] ->
  function updateView(refs) {
    showAllArrows();
    if (currentPage === 1) { 
	hideLeftArrow();
    }
    
    if (lastPage === currentPage) {
      hideRightArrow();
    }

    displayReferences(refs);
  }

  // str ->
  function onArrowClick(arrowSide) {
    retriving(true);
    updateCurrentPage(arrowSide);
    getRefs(currentPage)
      .done(function(refs) {
	if (refs.length <= 10) {
	  lastPage = currentPage;  // then this is the last page
	}
	updateView(refs);
	retriving(false);
      })
      .fail(function(){
	console.error('failed to fetch more references');
	retriving(false);
      });
  }


  function handlers() {
    $('#source-links-left-arrow').click(function(){
      console.log('you clicked the left arrow');
      onArrowClick('left');
    });

    $('#source-links-right-arrow').click(function(){
      console.log('you clicked the right arrow');
      onArrowClick('right');
    });

  }

  return {
    init: function(_entityId) {
      entityId = _entityId; // set entity_id
      console.log('initialized with: ' + entityId);
      handlers();
      onArrowClick('left');
    },
    getRefs: getRefs
  };

  
})(jQuery);


