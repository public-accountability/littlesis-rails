var addRelationship = function() {
  /*
   .rel-search -> show during selection process
   .rel-add -> show during add-relationship process. Start hidden
  */

  var categoriesText = [
      "",
      "Position",
      "Education (as a student)",
      "Membership",
      "Family",
      "Donation/Grant",
      "Service/Transaction",
      "Lobbying",
      "Social",
      "Professional",
      "Ownership",
      "Hierarchy",
      "Generic"
  ];

  $('#search-button').click(function(e){
    e.preventDefault();
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

  // <Table> -> 
  function selectButtonHandler(table) {
    $('#results-table tbody').on( 'click', 'button', function (e) {
      e.preventDefault(); // Prevents form from submitting
      var data = table.row( $(this).parents('tr') ).data();
      $('.rel-search').addClass('hidden'); // hide search elements
      $('.rel-add').removeClass('hidden'); // show add relationship elements
      $('#relationship-with-name').html( $('<a>', { href: data.url, text: data.name }) ); // add relationshipt-with entity-link
      $('#category-selection').html(categorySelector(data)); // add category selection
      categoryButtonsSetActiveClass(); // change '.active' on category buttons
    });
  }

  
  // {} -> HTML ELEMENT
  function categorySelector(data) {
    var entity1 = document.getElementById('entity-info').dataset.entitytype;
    var entity2 = data.primary_type;
    var buttonGroup = $('<div>', { class: 'btn-group-vertical', role: 'group', 'aria-label': 'relationship categories'});
    categories(entity1, entity2).forEach(function(categoryId){
      buttonGroup.append(
	$('<button>', {
	  type: 'button', 
	  class: 'btn btn-default', 
	  text: categoriesText[categoryId],
	  'data-categoryid': categoryId
	})
      );
    });
    return buttonGroup;
  }
  
  function categoryButtonsSetActiveClass() {
    $("#category-selection .btn-group-vertical > .btn").click(function(){
	$(this).addClass("active").siblings().removeClass("active");
    });
  }

  // str, str -> [int] | Throw Exception
  function categories(entity1, entity2) {
    var personToPerson = [1,3,4,5,6,7,8,9,12];
    var personToOrg = [1,2,3,5,6,7,10,12];
    var orgToPerson = [3,5,6,7,10,11,12];
    var orgToOrg = [1,2,3,5,6,7,10,12];
    if (entity1 === 'Person' && entity2 === 'Person') {
      return personToPerson;
    } else if (entity1 === 'Person' && entity2 === 'Org') {
      return personToOrg;
    } else if (entity1 === 'Org' && entity2 === 'Person') {
      return orgToPerson;
    } else if (entity1 === 'Org' && entity2 === 'Org') {
      return orgToOrg;
    } else {
      throw "Missing or incorrect primary extention type";
    }
  }

  function addReference() {
    $('#reference-form').submit(function(event){
      if (this.checkValidity()) {
	event.preventDefault();
      }
    });
  }

};
