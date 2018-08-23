(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'));
  } else {
    // Browser globals (root is window)
    root.RelationshipsDatatable = factory(root.jQuery, root.utility);
  }
}(this, function ($, utility) {
  var createElement = document.createElement.bind(document); // javascript! what a language!
  var columns = ["Related Entity", "Relationship", "Details", "Date(s)"];

  var TABLE_ID = "relationships-table";

  function createTable() {
    var table = createElement('table');
    table.className = "table table-striped table-bordered";
    table.id = "relationships-table";

    var thead = createElement('thead');
    var tr = createElement('tr');

    columns.forEach(function(c) {
      tr.appendChild(utility.createElementWithText('th', c));
    });
    
    thead.appendChild(tr);
    table.appendChild(thead);
    return table;
  }


  function insertTableIntoDom() {
    document
      .getElementById('relationships-datatable-container')
      .appendChild(createTable());
  }


  function start() {
    console.log('starting!');
    insertTableIntoDom();
  }

  return {
    start: start
  };

}));
