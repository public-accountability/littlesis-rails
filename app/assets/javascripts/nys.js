var nys = (function($, utility){
  
  function td(v){
    return "<td>" + v + "</td>";
  }

  function entity_link(entity){
    return '<a href="' + entity.url + '">' + entity.name + "</a>";
  }

  function rowClick(){
    $('tbody tr').click(function(){
      var entity_id = $(this).find('td')[0].innerText;
      var link = '/nys/candidates/new?entity='+ entity_id;
      window.location.replace(link);
    });
  }

  function createTable(d){
    $('#table-container').removeClass('hidden');
    d.slice(0,10).forEach(function(entity){
      var html = '<tr>' + td(entity.id) + td(entity_link(entity)) + td(entity.description ? entity.description : "" ) + '</tr>';
      $('tbody').append(html);
    });
    rowClick();
  }

  function entitySearch() {
    $("#entity-search-submit").click(function(e){
      e.preventDefault();
      $.getJSON('/search/entity', {q: $('#entity-search').val(), ext: 'Person' }, function(d){
	if (d.length > 0) {
          createTable(d);
	} else { 
          // show create new entity message 
	}
      });
    });
  }

  function newFilerUrl(entityId, query) {
    return "/nys/candidates/new?entity=" + entityId + "&query=" + encodeURIComponent(query);
  }

  function filerSearch() {
    $('#custom-search-btn').click(function(e){
      var entityId = utility.entityInfo('entityid');
      var query = $('#custom-search-input').val();
      window.location.href = newFilerUrl(entityId, query);
    });
  }
  
  return {
    entitySearch: entitySearch,
    filerSearch: filerSearch
  };


})(jQuery, utility);
