/**
 Editable bulk add relationships table 
 Helpful Inspiration: https://codepen.io/ashblue/pen/mCtuA
*/
var bulkAdd = (function($, utility){
  
  // This is the structure of table. The number and types of columns vary by
  // relationship type. See utility.js for more information
  // -> [[]]
  function relationshipDetails() {
    var category = Number($('#relationship-cat-select option:selected').val());
    var entityColumns = [ [ 'Name or ID', 'name', 'text'], ['Blurb', 'blurb', 'text'], ['Entity type', 'primary_ext', 'select'] ];
    return entityColumns.concat(utility.relationshipDetails(category));
  }

  // -> [ {} ]
  // same information as above represented as an object.
  function relationshipDetailsAsObject() {
    return relationshipDetails().map(function(x) {
      return {
	display: x[0],
	key: x[1],
	type: x[2]
      };
    });
  }

  // Adds <th> with title to table header
  // [] -> 
  function addColToThead(col) {
    $('#table thead tr').append(
      $('<th>', {
	text: col[0], 
	data: { 'colName': col[1], 'colType': col[2] }
      })
    );
  }

  // Creates Empty table based on the selected category
  function createTable() {
    $('#table table').html('<thead><tr></tr></thead><tbody></tbody>');
    relationshipDetails().forEach(addColToThead);
    $('#table thead tr').append('<th><span class="glyphicon glyphicon-plus table-add"></span></th>');
  }
  
  // AJAX request route: /search/entity
  // str, function -> callback([{}])
  function searchRequest(text, callback) {
    $.getJSON('/search/entity', {
      num: 10,
      q: text,
      no_summary: true
    })
      .done(function(result){
	callback(result.map(function(entity){
	  // set the value field to be the name for jquery autocomplete
	  return Object.assign({value: entity.name }, entity);
	}));
      })
      .fail(function() {
	callback([]);
      });
  }

  // options for the entity search autocomplete <td>
  var autocomplete = {
    contenteditable: 'true',
    autocomplete: {
      source: function(request, responce) {
	searchRequest(request.term, responce);
      },
      select: function( event, ui ) {
	event.preventDefault();
	var cell = $(this);
	//  requires order of table to be: name -> blurb -> entityType
	var blurb = cell.next();
	var entityType = blurb.next();
	// add link to cell
	cell.html( $('<a>', { href: 'https://littlesis.org' + ui.item.url, text: ui.item.name, target: '_blank' })) ;
	cell.attr('contenteditable', 'false');
	// store entity id in dataset
	cell.data('entityid', ui.item.id);
	// add reset-field option
	cell.append( 
	  $('<span>', { 
	    'class': 'glyphicon glyphicon-edit reset-name',
	    click: function() {
	      cell.empty();  // empty the cell
	      blurb.empty(); // empty blurb 
	      cell.attr('contenteditable', 'true'); // make cell editable again
	      cell.data('entityid', null); // remove the entity id 
	    }
	  })
	);
	
	blurb.text(ui.item.description ? ui.item.description : '');
	entityType.find('select').selectpicker('val', ui.item.primary_type);
      }
    }
  };

  function primaryExtRadioButtons() {
    // Using selectpicker with multiple and max-options 1 in order to get the
    // 'Nothing selected' message displayed.
    return $('<select>', { 
      'class': 'selectpicker',
      'data-width': 'fit'
    }).append('<option></option><option>Org</option><option>Person</option>');
  }

  // generates <td> for new row
  // [] -> Element
  function td(col) {
    if (col[2] === 'boolean') {  // boolean column
      return $('<td>').append('<input type="checkbox">');  // include checkbox
    } else if (col[1] === 'name') { // autocomplete for entity
      return $('<td>', autocomplete);
    } else if (col[1] === 'primary_ext') {
      return $('<td>').append(primaryExtRadioButtons());
    } 
    else {
      return $('<td>', { contenteditable: 'true'}); // return editable column
    }
  }
  
  // Adds a new blank row to the table
  function newBlankRow() {
    var removeTd = $('<td>').append('<span class="table-remove glyphicon glyphicon-remove"></span>');
    var row = $('<tr>').append(relationshipDetails().map(td).concat(removeTd));
    $('#table tbody').append(row);
    // Because we create the selectpicker after the dom has loaded, we must iniitalize it here:
    $('#table .selectpicker').selectpicker();
  }

  // Establishes listeners for:
  //   - click to add a new row
  //   - remove row
  //   - select a relationship category
  //   - upload data button click
  function domListeners() {
    $('#table').on('click', '.table-add', function() { newBlankRow(); });
    $('#table').on('click', '.table-remove', function() {
      $(this).parents('tr').detach();
    });
    $('#relationship-cat-select').change(function(x){ createTable(); });
    $('#upload-btn').click(function() {
      $('.bg-warning').removeClass('bg-warning');
      validate('#table');
      console.log(tableToJson('#table', relationshipDetailsAsObject()));
    });
  } 

  // This returns the cell data
  // Most types simply need to return the text inside the element.
  // Two expetions: checkboxes and <select>'s
  function extractCellData(cell, type) {
    if (type === 'boolean') {
      // Technically we should allow three values for this field: true, false, and null.
      // However, to keep things simple, right now the false/un-checked state defaults to null
      // So in this tool there is no way of saying that a person is NOT a board member.
      return cell.find('input').is(':checked') ? true : null; 
    } else if (type === 'select') {
      var selectpickerArr = cell.find('.selectpicker').selectpicker('val');
      return selectpickerArr ? selectpickerArr : null;
    } else {
      return cell.text();
    }
  }

  //  [{}], element -> {}
  function rowToJson(tableDetails, row) {
    var obj = {};
    tableDetails.forEach(function(rowInfo,i) {
      var cell = $(row).find('td:nth-child(' + (i + 1) + ')');
      obj[rowInfo.key] = extractCellData(cell, rowInfo.type);
    });
    return obj;
  }

  // str, [ {} ] -> [ {} ]
  // columns should be relationshipDetailsAsObject()
  // Given the selector of a <table> and it's associated column data
  // it returns the data as an array of objects
  function tableToJson(selector, columns) {
    var _rowToJson = rowToJson.bind(null, columns);
    return $(selector + ' tbody tr').map(function(){
      return _rowToJson(this);
    }).toArray();
  }

  // <td> Element -> false
  // displays validations and return false;
  function invalidDisplay(element) {
    $(element).addClass('bg-warning');
    return false;
  }

  // input: arr, element, function
  // calls the provided function on each cell in the row with these args:
  // rowInfo ({}), cell (element), cellData (various)
  function traverseRow(columns, row, func) {
    columns.forEach(function(rowInfo, i){
      var cell = $(row).find('td:nth-child(' + (i + 1) + ')');
      var cellData = extractCellData(cell, rowInfo.type);
      func(rowInfo, cell, cellData);
    });
  }

  // If cell is in valid it called invalidDisplay and returns false;
  // Otherwise it returns true
  // {}, element, * -> boolean
  function cellValidation(rowInfo, cell, cellData) {
    if (['name', 'primary_ext'].includes(rowInfo.key) && !cellData) {
      return invalidDisplay(cell);
    }
    if (cellData && rowInfo.type === 'date' && !utility.validDate(cellData)) {
      return invalidDisplay(cell);
    }
    return true;
  }
  
  // Verifies that each 
  function validate(selector) {
    var valid = true; // flag if table is valid
    var columns = relationshipDetailsAsObject();
    // for each row
    $(selector + ' tbody tr').each(function(){
      // for each cell in the row
      traverseRow(columns, this, function(rowInfo, cell, cellData){
	// highlighed cell if invalid and return status
	valid = cellValidation(rowInfo, cell, cellData);
      });
    });
    return valid;
  }

  return {
    relationshipDetails: relationshipDetails,
    relationshipDetailsAsObject: relationshipDetailsAsObject,
    createTable: createTable,
    tableToJson: tableToJson,
    search: searchRequest,
    validate: validate,
    cellValidation: cellValidation,
    invalidDisplay: invalidDisplay,
    init: function() { 
      domListeners();
    }
  };

})(jQuery, utility);;
