/**
 Editable bulk add relationships table
 
 Helpful Inspiration: https://codepen.io/ashblue/pen/mCtuA
*/
var bulkAdd = (function($, utility){
  
  function isNil(x) { return !Boolean(x);}
  
  // generates <td> tag
  // input: str, [boolean, str, str]
  function td(text, editable, cls, append) {
    editable = isNil(editable) ? 'false' : 'true';
    cls = isNil(editable) ? '' : cls;
    append = isNil(append) ? '' : append;
    return $('<td>', { contenteditable: editable, text: text, class: cls}).append(append);
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

  function tableSetup() {
    
  }

  function appendNewRow() {
    var checkbox = '<input type="checkbox">';
    $('#table').find('tbody').append(
      $('<tr>').append( [
	td('Entity Name or ID', true, 'col-1'),
	td('', false, 'col-2', relationshipSelect()),
	td('', true, 'col-3'),
	td('', true, 'col-4'),
	td('', true, 'col-5'),
	td('', false, 'col-6', checkbox),
	td('', true, 'col-7'),
	td('', true, 'col-8'),
	td('', false, 'col-9', checkbox),
	td('', true, 'col-10'),
	td('', true, 'col-11'),
	td('', true, 'col-12'),
	td('', false, 'col-13', '<span class="table-remove glyphicon glyphicon-remove"></span>')
      ])
    );
  }

  function addRemove() {
    $('.table-add').click(appendNewRow);
    $('#table').on('click', '.table-remove', function() {
      $(this).parents('tr').detach();
    });
  } 

  function exportClick() {
    $('#export-btn').click(function() {
      $('table').find('tr')
    });
  }
  
  return {
    appendNewRow: appendNewRow,
    relationshipSelect: relationshipSelect, 
    init: function() { 
      // addRemove();
      // appendNewRow();
    }
  };

})(jQuery, utility);;
