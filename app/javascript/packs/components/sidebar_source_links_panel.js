/**
  Show recent references for profile page sidebar

  selectors:
  #source-links-left-arrow
  #source-links-right-arrow
  #source-links-container  (ul)

*/
var sidebarSourceLinks = (function($){
  var entityId = null
    var lastPage = null
    var currentPage = 1

    // integer -> JqueryAjaxPromiseThing
    function getRefs(page) {
      var params = { entity_id: entityId, page: page }
      return $.getJSON("/references/entity", params)
    }

  // updates currentPage after click
  function updateCurrentPage(arrowSide) {
    if (arrowSide === 'right') {
      currentPage += 1
    } else if (arrowSide === 'left') {
      if (currentPage > 1) {
        currentPage -= 1
      }
    } else {
      throw "arrowSide must  be 'left' or 'right'"
    }
  }

  // {} -> html element
  function refToHtml(ref){
    var name = (ref.name && ref.name.length > 0) ? ref.name : ref.url
      var displayName = (name.length > 40) ? (name.substring(0,37) + '...') : name

      return $('<li>').append(
          $('<a>', {
            href: ref.url,
            text: displayName,
            target: '_blank'
          }))
  }

  // redisplays references list
  // [{}] ->
  function displayReferences(refs) {
    $('#source-links-container').empty()
      refs.forEach(function(ref){
        $('#source-links-container')
          .append(refToHtml(ref))
      })
  }

  function hideRightArrow(){
    $('#source-links-right-arrow').addClass('invisible')
  }

  function hideLeftArrow(){
    $('#source-links-left-arrow').addClass('invisible')
  }

  function showAllArrows() {
    $('#source-links-right-arrow').removeClass('invisible')
      $('#source-links-left-arrow').removeClass('invisible')
  }

  // updates arrows and re-renders reference list
  // [{}] ->
  function updateView(refs) {
    showAllArrows()
      if (currentPage === 1) {
        hideLeftArrow()
      }

    if (lastPage && lastPage === currentPage) {
      hideRightArrow()
    }

    displayReferences(refs)
  }

  // str ->
  function onArrowClick(arrowSide) {
    updateCurrentPage(arrowSide)
      getRefs(currentPage)
      .done(function(refs) {
        if (refs.length < 10) {
          console.log('this is the last page')
            lastPage = currentPage // then this is the last page
        }
        updateView(refs)
      })
    .fail(function(){
      console.error('failed to fetch more references')
    })
  }


  function handlers() {
    $('#source-links-left-arrow').click(function(){
      onArrowClick('left')
    })

    $('#source-links-right-arrow').click(function(){
      onArrowClick('right')
    })

  }

  return {
    init: function(_entityId) {
      entityId = _entityId // set entity_id
      handlers()
      onArrowClick('left')
    },
    getRefs: getRefs
  }


})(jQuery)

$(document).ready(function(){
  sidebarSourceLinks.init($('#sidebar-source-links').data('entityId'))
})
