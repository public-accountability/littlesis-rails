import utility from '../common/utility'

export default function nysSearch() {
  let nys = {};

  function td(v){
    return "<td>" + v + "</td>";
  }

  function entity_link(entity){
    return '<a href="' + entity.url + '">' + entity.name + "</a>";
  }

  function rowClick(type){
    $('tbody tr').click(function(){
      var entity_id = $(this).find('td')[0].innerText;
      var link = '/nys/' + type + '/new?entity='+ entity_id;
      window.location.replace(link);
    });
  }

  // input: 'Person' | 'Org'
  // output: 'candidates' | 'pacs'
  function primaryExtToType(primaryExt) {
    if (!['Person', 'Org'].includes(primaryExt)) { throw "This must be called with 'Org' or 'Person'"; }
    return (primaryExt === 'Org') ? 'pacs' : 'candidates';
  }

  function createTable(d, primaryExt){
    $('#table-container').removeClass('hidden');
    d.slice(0,10).forEach(function(entity){
      var html = '<tr>' + td(entity.id) + td(entity_link(entity)) + td(entity.blurb ? entity.blurb : "" ) + '</tr>';
      $('tbody').append(html);
    });
    rowClick(primaryExtToType(primaryExt));
  }

  // input: 'Org' or 'Person'
  nys.entitySearch = function(primaryExt) {
    if (!['Person', 'Org'].includes(primaryExt)) {
      var msg  = "nys.entitySearch must be called with 'Org' or 'Person'. It was called with " + primaryExt;
      throw msg;
    }
    $("#entity-search-submit").click(function(e){
      e.preventDefault();
      $.getJSON('/search/entity', {q: $('#entity-search').val(), ext: primaryExt }, function(d){
	if (d.length > 0) {
          createTable(d, primaryExt);
	} else { 
          // show create new entity message 
	}
      });
    });
  }

  function newFilerUrl(entityId, primaryExt, query) {
    return "/nys/" + primaryExtToType(primaryExt) + "/new?entity=" + entityId + "&query=" + encodeURIComponent(query);
  }

  nys.filerSearch = function() {
    $('#custom-search-btn').click(function(e){
      var entityId = utility.entityInfo('entityid');
      var primaryExt = utility.entityInfo('entitytype');
      var query = $('#custom-search-input').val();
      window.location.href = newFilerUrl(entityId, primaryExt, query);
    });
  }

  return nys;
}
