/**
 Editable bulk add relationships table
 
 Helpful Inspiration: https://codepen.io/ashblue/pen/mCtuA
*/
var bulkAdd = (function($){

  function test() { return 'test'; }
  
  function appendNewRow() {
    $('#table').find('tbody').append(
      $('<tr>').append( [
	$('<td>', { contenteditable: 'true', text: 'Entity Name'}),
	$('<td>', { contenteditable: 'true', text: 'Blurb'}),
	$('<td>').append('<span class="table-remove glyphicon glyphicon-remove"></span>')
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
    test: test,
    init: function() { 
      addRemove();
      appendNewRow();
    }
  };

})(jQuery);;
