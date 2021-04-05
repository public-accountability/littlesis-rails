import datatable from 'datatables.net'
import NewReferenceForm from './new_reference_form'
import ExistingReferenceWidget from './existing_reference_selector'


export default function RelationshipCreationFlow(){
  /*
   .rel-search -> show during selection process
   .rel-results -> table results
   .rel-add -> show during add-relationship process. Start hidden
  */
  var categoriesText = [
      "",
      "Position",
      "Education",
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

  // holds entity ids
  var entity1_id = null;
  var entity2_id = null;
  var selected_entity_data = null;
  // Reference Components
  var newReferenceForm;
  var existingReferences;

  var parentOrgSpan = '<span class="badge badge-light badge-pill ml-1">Parent Org</span>'

  // Creates a new datatable
  // {} ->
  function createDataTable(data) {
    $('#results-table').empty(); // Necessary for the search to work multiple times on the same page.
    var table = $('#results-table').DataTable({
	data: data,
	columns: [
	  {
	    data: null,
	    defaultContent: '<button type="button" class="btn btn-success btn-sm">select</button>'
	  },
	  {
	    title: 'Name',
	    render: function(data, type, row) {
	      return [
                '<a href="',
                row.url,
                ' target="_blank">',
                row.name,
                row.is_parent ? parentOrgSpan : '',
                '</a>'
              ].join('')

	    }
	  },
	  {
	    data: 'blurb',
	    title: 'Summary'
	  }
	],
	ordering: false,
	searching: false,
	lengthChange: false,
	info: false,
	destroy: true // https://datatables.net/reference/option/destroy
      });
      selectButtonHandler(table);
  }

  // Used by selectButtonHandler & in $('#new_entity').submit()
  function showAddRelationshipForm(data) {
    // update 'global' vars:
    entity2_id = String(data.id);
    selected_entity_data = data;

    $('.rel-new-entity').addClass('hidden'); // hide new entity elements
    $('.rel-search').addClass('hidden'); // hide search elements
    $('.rel-add').removeClass('hidden'); // show add relationship elements
    $('#relationship-with-name').html( $('<a>', { href: data.url, text: data.name }) ); // add relationship-with entity-link
    $('#category-selection').html(categorySelector(data)); // add category selection

    // change '.active' on category buttons
    // and search for similar entities;
    onCategorySelectHandlers();
    referencesInit( [utility.entityInfo('entityid'), entity2_id] );
  }

  // <Table> ->
  function selectButtonHandler(table) {
    $('#results-table tbody').on( 'click', 'button', function (e) {
      e.preventDefault(); // Prevents form from submitting
      var data = table.row( $(this).parents('tr') ).data();
      showAddRelationshipForm(data);
    });
  }


  // {} -> HTML ELEMENT
  function categorySelector(data) {
    var entity1_primary_ext = utility.entityInfo('entitytype');
    var entity2_primary_ext = data.primary_ext;
    var buttonGroup = $('<div>', { class: 'btn-group-vertical', role: 'group', 'aria-label': 'relationship categories'});
    categories(entity1_primary_ext, entity2_primary_ext).forEach(function(categoryId){
      var buttonClass = 'category-select-button' + ( (categoryId === 7) ? ' disabled' : '' );
      buttonGroup.append(
	$('<button>', {
	  type: 'button',
	  class: buttonClass,
	  text: categoriesText[categoryId],
	  'data-categoryid': categoryId
	})
      );
    });
    return buttonGroup;
  }

  function onCategorySelectHandlers() {
    $("#category-selection .btn-group-vertical > .category-select-button").click(function(){
      categoryButtonsSetActiveClass(this);
      lookForSimilarRelationship();
      $('#similar-relationships').addClass('hidden');
      $('#similar-relationships').popover('dispose');
    });
  }

  // Submits ajax request to /relationships/find_similar
  // and calls hasSimilarRelationships with the response
  function lookForSimilarRelationship(){
    var request = { entity1_id: entity1_id, entity2_id: entity2_id, category_id: category_id() };
    $.getJSON('/relationships/find_similar', request)
      .done(hasSimilarRelationships)
      .fail(function(){
	console.error('ajax request to /relationships/find_similar failed');
      });
  }

  function hasSimilarRelationships(relationships) {
    if (relationships.length == 0) { return; }
    $('#similar-relationships').removeClass('hidden').fadeIn();
    $('#similar-relationships').popover({
      content: popoverContent(relationships),
      html: true
    });
  }

  function popoverContent (relationships) {
    var text = "There already exists " + relationships.length + " " + categoriesText[category_id()] + " relationship";
    (relationships.length > 1) ? text += 's. ' : text += '. ';    // pluralize
    return $('<span>', {text: text})
      .append($('<br>'))
      .append(relationshipLink(relationships));
  }

  function relationshipLink(relationships) {
    var examine = ' to examine ';
    examine += (relationships.length > 1) ? 'one' : 'it';
    return $('<a>', {text: 'Click here', href: "/relationships/" + relationships[0].id, target: '_blank'})
      .append( $('<span>', { text:  examine}) );
  }

  function displayCreateNewEntityDialog(name) {
    $('#entity_name').val(name);
    $('.rel-results').addClass('hidden');
    $('.rel-new-entity').removeClass('hidden');
  }

  function categoryButtonsSetActiveClass(elem) {
    $(elem).addClass("active").siblings().removeClass("active");
  }

  // str, str, [school] -> [int] | Throw Exception
  function categories(entity1, entity2) {
    var personToPerson = [1,4,5,6,7,8,9,12];
    var personToOrg = [1,2,3,5,6,7,10,12];
    var orgToPerson = [1,3,5,6,7,10,12];
    var orgToOrg = [3,5,6,7,10,11,12];
    if (entity1 === 'Person' && entity2 === 'Person') {
      return personToPerson;
    } else if (entity1 === 'Person' && entity2 === 'Org') {
      return personToOrg;
    } else if (entity1 === 'Org' && entity2 === 'Person') {

      // if entity is a school, provide the option to
      // create a student relationship
      if (typeof utility.entityInfo('school') !== 'undefined' && utility.entityInfo('school') === 'true') {
	orgToPerson.splice(1, 0, 2);
      }
      return orgToPerson;

    } else if (entity1 === 'Org' && entity2 === 'Org') {
      return orgToOrg;
    } else {
      throw "Missing or incorrect primary extension type";
    }
  }

  function referencesInit(entityIds) {
    newReferenceForm = new NewReferenceForm('#new-reference-form');
    existingReferences = new ExistingReferenceWidget(entityIds);
  }

  // boolean ->
  function submissionInProgress(submitting) {
    if (Boolean(submitting)) {
      // show loading logic
    } else {
      // hide loading logic
    }
  }

  // -> int | null
  function category_id() {
    return ($('#category-selection button.active').length > 0) ? $('#category-selection button.active').data().categoryid : null;
  }


  /**
   * Swaps global vars entity1_id and entity2_id
   */
  function swapEntityIds() {
    var tmp = entity1_id;
    entity1_id = entity2_id;
    entity2_id = tmp;
  }


  /**
   categories() defines the acceptable valid relationship options
   for a given two entities. As a convenience we allow some relationships
   to be selected in reverse, where the correct direction of the relationship
   can be determined. This function reverses the entity ids in those situations.

   Org-->People relationships are reversed for these categories
     - Position (1)
     - Education (2)
     - Membership (3)
     - Ownership(10)
  */
  function reverseEntityIdsIf() {
    var catId = category_id();

    if ( [1,2,3,10].includes(catId) &&
         utility.entityInfo('entitytype') === 'Org' &&
         selected_entity_data.primary_ext === 'Person') {
      swapEntityIds();
    }
  }

  // -> object
  function submissionData() {
    reverseEntityIdsIf();
    return {
      relationship: {
	entity1_id: entity1_id,
	entity2_id: entity2_id,
	category_id: category_id()
      },
      reference: referenceData()
    };
  }

  function referenceData() {
    if ($('#new-reference-container').is(':visible')) {
      return newReferenceForm.value();
    };

    if (existingReferences.selection) {
      return { "document_id": existingReferences.selection.id };
    };

    return { "document_id": null };
  }

  function submit() {
    $('#errors-container').empty();
    var sd = submissionData();
    if (catchErrors(sd)) {

      $.post('/relationships', sd, null, 'json')
      	.done(function(data, textStatus, jqXHR) {
      	  // redirect to the edit relationship page
      	  window.location.replace("/relationships/" + data.relationship_id + "/edit?new_ref=true");
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
    var errors = {};
    if (!formData.relationship.category_id){
      errors.category_id = true;
    }

    if (typeof formData.reference.document_id === 'undefined') {

      if (!formData.reference.name) {
	errors.reference_name = true;
      }

      if (!formData.reference.url) {
	errors.url = true;
      } else if (!utility.validURL(formData.reference.url)) {
	errors.url = 'INVALID';
      }

    } else if (formData.reference.document_id === null) {
      errors.no_selection = true;
    }


    if ($.isEmptyObject(errors)) {
      return true;
    } else {
      displayErrors(errors);
      return false;
    }

  }

  /**
   Possible errors from the server:
     errors.category_id
     errors.entity1_id
     errors.entity2_id
     errors.base

     We are going to mostly deal with three errors:
      - missing category_id
      - missing or invalid source url

     Although rails is going to send us back errors, we will also try
     to catch the errors before submitting.

     {} ->
   */
  function displayErrors(errorData) {
    var alerts = [];
    var errors = errorData;

    if (Boolean(errors.base)) {
      alerts.push(alertDiv(errors.base));
    }

    if (Boolean(errors.reference_name)) {
      alerts.push(alertDiv('Missing information ', "Don't forget to add a reference name"));
    }

    if (Boolean(errors.no_selection)) {
      alerts.push(alertDiv('Missing information ', "Don't forget to select an existing reference"));
    }

    if (Boolean(errors.url)) {
      if (errors.url === 'INVALID') {
	alerts.push(alertDiv('Invalid data: ', "The reference url is invalid"));
      } else {
	alerts.push(alertDiv('Missing Url: ', "The reference url is missing"));
      }
    }

    if (Boolean(errors.category_id)) {
      alerts.push(alertDiv('Missing information ', "Don't forget to select a relationship category"));
    }

    if ( Boolean(errors.entity1_id) || Boolean(errors.entity2_id) ) {
      alerts.push(alert('Something went wrong :( ', "Sorry about that! Please contact admin@littlesis.org"));
    }

    $('#errors-container').html(alerts); // display the errors
    alertFadeOut();
  }

  function alertFadeOut() {
    var fade = function() {
      $('div.alert').fadeOut(2000);
    };
    setTimeout(fade, 3000);
  }

  function alertDiv(title, message) {
    return $('<div>', {class: 'alert alert-danger', role: 'alert' })
      .append($('<strong>', {text: title}))
      .append($('<span>', {text: message}));
  }

  function init() {

    entity1_id = utility.entityInfo('entityid');
    // entity1_id gets set after selection.

    // submits create relationships request
    // after button is clicked.
    $('#create-relationship-btn').click(function(e){
      submit();
    });

    // Overrides default action of submit new entity form
    $('#new_entity').submit(function(event) {
      event.preventDefault();
      $('#new-entity-errors').empty();
      $.post('/entities', $('#new_entity').serialize())
	.done(function(response){
	  if (response.status === 'OK') {
	    showAddRelationshipForm(response.entity);
	  } else {
	    $.each(response.errors, function(key, val) {
	      var field = (key === 'primary_ext') ? 'type' : key;
	      $('#new-entity-errors').append(alertDiv(field, ":  " + val));
	    });
	  }
	});
    });

    // Searches for name in search bar and then renders table with results
    $('#search-button').click(function(e){
      e.preventDefault();
      $('.rel-new-entity').addClass('hidden');
      $('.rel-results').removeClass('hidden');
      var name = $('#name-to-search').val();
      $.getJSON('/search/entity', { q: name, include_parent: true }, function(data) {
	if (data.length > 0) {
	  createDataTable(data);
	} else {
	  displayCreateNewEntityDialog(name);
	}
      });
    });

    // Switches to the "new entity" option after user clicks
    // on "click here to create a new entity"
    $('#cant-find-new-entity-link').click(function(e){
      displayCreateNewEntityDialog("");
    });


    $('#toggle-reference-form').click(function(){
      $(this).find('.btn').toggleClass('active');
      $(this).find('.btn').toggleClass('btn-secondary');
      $(this).find('.btn').toggleClass('btn-outline-secondary');
      $('#existing-reference-container').toggle();
      $('#new-reference-container').toggle();
      // if $('#new-reference-container').is(':visible') {}
    });
  }

  return {
    "init": init,
    "debug": function() {
      return {
	"entity1_id": entity1_id,
	"entity2_id": entity2_id,
	"selected_entity_data": selected_entity_data
      };
    },
    "_referenceData": referenceData
  };
}
