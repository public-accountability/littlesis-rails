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
    var entityColumns = [ [ 'Name or ID', 'name', 'text'], ['Blurb', 'blurb', 'text'], ['Entity type', 'primary_ext', 'text'] ];
    return entityColumns.concat(utility.relationshipDetails(category));
  }

  // -> [ {} }
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


  // generates <td> for new row
  // [] -> Element
  function td(col) {
    var isBooleanColumn = col[2] === 'boolean';
    var td = $('<td>', { contenteditable: isBooleanColumn ? 'false' : 'true' });
    // include checkbox if boolean
    return isBooleanColumn ? td.append('<input type="checkbox">') : td;
  }
  
  // Adds a new blank row to the table
  function newBlankRow() {
    var removeTd = $('<td>').append('<span class="table-remove glyphicon glyphicon-remove"></span>');
    var row = $('<tr>').append(relationshipDetails().map(td).concat(removeTd));
    $('#table tbody').append(row);
  }

  // Sets up listeners for:
  //   - click to add a new row
  //   - remove row
  //   - select a relationship category
  function domListeners() {
    $('#table').on('click', '.table-add', function() { newBlankRow(); });
    $('#table').on('click', '.table-remove', function() {
      $(this).parents('tr').detach();
    });
    $('#relationship-cat-select').change(function(x){ createTable(); });
  } 

  // This returns the cell data according to it's type
  // Most types simply need to return the text, but a few,
  // such as boolean require a different step
  function extractCellData(cell, type) {
    if (type === 'boolean') {
      // Technically we should allow three values for this field: true, false, and null.
      // However, to keep things simple, right now the false/un-checked state defaults to null
      // So in this tool there is no way of saying that a person is NOT a board member.
      return cell.find('input').is(':checked') ? true : null; 
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

  // str -> [ {} ]
  // Given the selector of a <table> it returns the data as an array
  // of objects
  function tableToJson(selector) {
    var _rowToJson = rowToJson.bind(null, relationshipDetailsAsObject());
    return $(selector + ' tbody tr').map(function(){
      return _rowToJson(this);
    }).toArray();
  }

  function exportClick() {
    $('#export-btn').click(function() {
      console.log(tableToJson('#table'));
    });
  }
  
  return {
    relationshipDetails: relationshipDetails,
    createTable: createTable,
    tableToJson: tableToJson,
    init: function() { 
      domListeners();
      exportClick();
    }
  };

})(jQuery, utility);;
