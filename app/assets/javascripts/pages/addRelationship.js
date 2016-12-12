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
  
  var entity1_id = entityInfo('entityid');
  var entity2_id = null; // this gets sets after selection.

  function entityInfo(info) {
    return document.getElementById('entity-info').dataset[info];
  }

  
  // submits create relationships request
  // after button is clicked.
  $('#create-relationship-btn').click(function(e){ 
    submit(); 
  });

  
  // Searches for name in search bar and then renders table with results
  //
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
      entity2_id = String(data.id); // update 'global' var. 

      $('.rel-search').addClass('hidden'); // hide search elements
      $('.rel-add').removeClass('hidden'); // show add relationship elements
      $('#relationship-with-name').html( $('<a>', { href: data.url, text: data.name }) ); // add relationship-with entity-link
      $('#category-selection').html(categorySelector(data)); // add category selection

      categoryButtonsSetActiveClass(); // change '.active' on category buttons
      recentReferences( [entityInfo('entityid'), entity2_id] );
    });
  }

  
  // {} -> HTML ELEMENT
  function categorySelector(data) {
    var entity1 = entityInfo('entitytype');
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

  // [int] -> null
  // Gets recent references from /references/recent and populates the
  // list of <select> options
  function recentReferences(entities) {
    var newReferenceOption = $('<option>', {value: 'NEW', selected: "selected", text: "Add a new source link" });
    $.getJSON('/references/recent', {'entity_ids': entities })
      .done(function(references) {
	$('#existing-sources-select').html(
	  references.slice(0,10).map(function(ref){
	    return $('<option>', {
   	      value: ref.id,
   	      text: ref.name
	    }).data(ref); // add reference data to element
	  }).concat(newReferenceOption)
	);
	fillInReferenceFields();
      })
      .fail(function() {
	$('#existing-sources-select').html(newReferenceOption);
      });
  }

  function fillInReferenceFields() {
    document.getElementById('existing-sources-select')
      .addEventListener('change', function(){
	var ref = $(this).find(":selected").data();
	$('#reference-name').val(ref.name);
	$('#reference-url').val(ref.source);
	$('#reference-date').val(ref.publication_date);
	$('#reference-excerpt').val(ref.source_detail);
      });
  }

  // boolean -> 
  function submissionInProgress(submitting) {
    if (Boolean(submitting)) {
      // show loading logic
    } else {
      // hide loading logic
    } 
  } 

  // -> object
  function submissionData() {
    return {
      relationship: {
	entity1_id: entity1_id,
	entity2_id: entity2_id,
	category_id: ($('#category-selection button.active').length > 0) ? $('#category-selection button.active').data().categoryid : null
      },
      reference: {
	name: $('#reference-name').val(),
	source_detail: $('#reference-excerpt').val(),
	source: $('#reference-url').val(),
	publication_date: $('#reference-date').val(),
	ref_type: $('#reference-type').val()
      }
    };
  }

  function submit() {
    $('#errors-container').empty();
    var sd = submissionData();
    if (catchErrors(sd)) { 
      
      $.post('/relationships', sd)
	.done(function(data, textStatus, jqXHR) {
	  // redirect to the edit relationship page
	  window.location.replace("/relationship/edit/id/" + data.relationship_id + "?ref=auto");
	})
	.fail(function(data) {
	  // assuming here that the status code is 400 because of a bad request. we should person also  consider what would happen if the request fails for different reasons besides the submission of invalid or missing information.
	  displayErrors(data.responseJSON);
	}); 
    }
  } 

  // {} -> boolean
  // If there are errors, it will display error messages and return false
  // otherwise it returns true
  function catchErrors(formData) {
    var errors = {relationship: {}, reference: {} };

    if (!formData.relationship.category_id){
      errors.relationship.category_id = true;
    }
    
    if (!formData.reference.name) {
      errors.reference.name = true;
    }

    if (!formData.reference.source) {
      errors.reference.source = true;
    } else if (!validURL(formData.reference.source)) {
      errors.reference.source = 'INVALID';
    }

    if ($.isEmptyObject(errors.relationship) && $.isEmptyObject(errors.reference)) {
      return true;
    } else {
      displayErrors(errors);
      return false;
    }
    
  }
  
  /**
   Possible errors from the server:
     errors.relationship.category_id
     errors.relationship.entity1_id
     errors.relationship.entity2_id
     errors.reference.source
     errors.referene.name

     We are going to mostly deal with three errors:
      - missing category_id
      - missing or invalid source url
      - missing reference name

     Although rails is going to send us back errors, we will also try 
     to catch the errors before submitting.

      This is the general format, although the message isn't used.
     { 
       relationship: {
          "field": "message"   
        },
       reference: {
          "field": message"
         }
      }

     {} -> 
   */
  function displayErrors(errorData) {
    var alerts = [];
    var errors = $.extend({reference: {}, relationship: {} }, errorData);

    if (Boolean(errors.reference.source)) {
      if (errors.reference.source === 'INVALID') {
	alerts.push(alert('Invalid data ', "Please enter a correct url"));
      } else {
	alerts.push(alert('Missing information ', "Please submit a url"));
      }
    }

    if (Boolean(errors.reference.name)) {
      alerts.push(alert('Missing information ', 'Please include a name for the source'));
    }

    if (Boolean(errors.relationship.category_id)) {
      alerts.push(alert('Missing information ', "Don't forget to select a relationship category"));
    } 
    
    if ( Boolean(errors.relationship.entity1_id) || Boolean(errors.relationship.entity1_id) ) {
      alerts.push(alert('Something went wrong :( ', "Sorry about that! Please contact admin@littlesis.org"));
    }

    $('#errors-container').html(alerts); // display the errors
  } 

  function alert(title, message) {
    return $('<div>', {class: 'alert alert-danger', role: 'alert' })
      .append($('<strong>', {text: title}))
      .append($('<span>', {text: message}));
    
  } 


  /**
   Simple url validation. Tests if it begins with 'http://' or 'https://' and is
   followed by at least one character followed by a dot followed by another character. 
   
   So yes, http://1.blah is a valid url according to these standards...we could go crazy with the regexs...https://mathiasbynens.be/demo/url-regex...but this is FINE
   */
  function validURL(str) {
    var pattern = RegExp('^(https?:\/\/)(.+)[\.]{1}.+$');
    return pattern.test(str);
  }
  
};
