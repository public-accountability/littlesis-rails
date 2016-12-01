var addRelationship = function() {

  $('#search-button').click(function(){
    $.getJSON('/search/entity', {q: $('#name-to-search').val() }, function(data) {
      var table = $('#results-table').DataTable({
	data: data,
	columns: [
	  { 
	    data: null, 
	    defaultContent: '<button>select</button>' 
	  },
	  { 
	    title: 'Name', 
	    render: function(data, type, row) {
	      return '<a href="' + row.url + '" target="_blank">' + row.name;
	    }
	  },
	  { 
	    data: 'description', 
	    title: 'Summary' 
	  },
	],
	ordering: false,
	searching: false,
	lengthChange: false,
	info: false,
	destroy: true // https://datatables.net/reference/option/destroy
      });

      selectButtonHandler(table);
    });
  });

  function selectButtonHandler(table) {
    $('#results-table tbody').on( 'click', 'button', function () {
      var data = table.row( $(this).parents('tr') ).data();

      $('.rel-search').addClass('hidden'); // hide search elements
      $('.rel-add').removeClass('hidden'); // show add relationship elements
      $('#relationship-with-name').html(
	$('<a>', { href: data.url, text: data.name }) // add relationshipt-with entity-link
      );
    });
  }

};
