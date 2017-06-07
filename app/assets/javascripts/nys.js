var nys = (function($){
  
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

  return {
    entitySearch: entitySearch 
  };


})(jQuery);
