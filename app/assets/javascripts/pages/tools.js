/**
 Editable bulk add relationships table
 
 Helpful Inspiration: https://codepen.io/ashblue/pen/mCtuA
*/
var bulkAdd = (function($, utility){
  
  // generates <td> tag
  // input [str]
  function td(col) {
    var isBooleanColumn = col[2] === 'boolean';
    var editable = isBooleanColumn ? 'false' : 'true';
    var td = $('<td>', { contenteditable: editable, text: '' });
    if (isBooleanColumn) {
      // include checkbox if boolean
      return td.append('<input type="checkbox">');
    } else {
      return td;
    }
  }

  function relationshipSelect() {
    var categories = (utility.entityInfo('entitytype') === 'Org') ?
	  utility.range(13, [4,7,8,9]) :
	  utility.range(13, [7]);
    
    var options = categories.map(function(i) {
      return $('<option>', { value: i, text: utility.relationshipCategories[i] });
    });
    return $('<select>').append(options);
  }
  
  // Adds column titled (located at col[0]) to thead
  // [ string ] -> 
  function addColToThead(col) {
    $('#table thead tr').append($('<th>', {text: col[0] }));
  }
  
  // recreates table with provded relationship category
  // int -> 
  function createTable(selectedCat) {
    $('#table table').html('<thead><tr></tr></thead><tbody></tbody>');
    utility.relationshipDetails(selectedCat).forEach(addColToThead);
    $('#table thead tr').append('<th><span class="glyphicon glyphicon-plus table-add"></span></th>');
  }

  // Sets up table according to selected relationship
  function tableSetup() {
    $('#relationship-cat-select').change(function(x){
      createTable(Number($(this).find('option:selected').val()));
    });
  }

  function relationshipDetails() {
    var category = Number($('#relationship-cat-select option:selected').val());
    return utility.relationshipDetails(category);
  }

  function appendNewRow() {
    var removeTd = $('<td>').append('<span class="table-remove glyphicon glyphicon-remove"></span>');
    var row = $('<tr>').append(relationshipDetails().map(td).concat(removeTd));
    $('#table tbody').append(row);
  }

  function addRemove() {
    $('#table').on('click', '.table-add', function() {
      appendNewRow();
    });
    $('#table').on('click', '.table-remove', function() {
      $(this).parents('tr').detach();
    });
  } 

  function exportClick() {
    $('#export-btn').click(function() {
    });
  }
  
  return {
    appendNewRow: appendNewRow,
    relationshipSelect: relationshipSelect,
    relationshipDetails: relationshipDetails,
    createTable: createTable,
    init: function() { 
      tableSetup();
      addRemove();
    }
  };

})(jQuery, utility);;
