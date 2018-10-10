(function (root, factory) {
  root.EntityMatcher = factory(root.jQuery, root.utility);
}(this, function ($, util) {

  // Helper functions ------------------------------------------//

  var matchExistsAndIsDisplay = function(row, type) {
    return row.entity_match && type === 'display';
  };

  // ---------------------------------------------------------- //

  /**
   * Rendering functions (static functions)
   */
  var renders = {
    
    "entityMatch": function(data, type, row, meta) {
      if (matchExistsAndIsDisplay(row, type)) {
	return util.createLink(
	  util.entityLink(row.entity_match.id, row.entity_match.name, row.entity_match.primary_ext),
	  row.entity_match.name
	).outerHTML;
      } else {
	return '';
      }
    },

    "matchButtons": function(data, type, row, meta) {
      if (row.entity_match) {
	return util.createElement({
	  "tag": 'button',
	  "text": "Match this row",
	  "class": 'match-button'
	}).outerHTML;
	
      } else {
	return '';
      }
    }

  };

  var matchedEntityColumns = [
    { "data": null, "title": 'Matched Entity', "render": renders.entityMatch },
    { "data": null, "title": 'Match this row', "render": renders.matchButtons }
  ];

  var baseDatatableOptions = {
    "processing": true,
    "serverSide": true,
    "ordering": false,
  };

  /**
   * Configurable table for matching a dataset
   * to LittleSis Entities
   *
   * @param {Object} config
   */
  function EntityMatcher(config) {
    this.config = config;
    this.rootElement = config.rootElement || '#entity-match-table';
    this.endpoint = config.endpoint;
    this.columns = config.columns.concat(matchedEntityColumns);
    this.datatableOptions = Object.assign({},
					  baseDatatableOptions,
					  { "ajax": this.endpoint, "columns": this.columns });
  }

  
  /**
   * Handles clicking on <button class="match-button">
   */
  EntityMatcher.prototype.buttonHandler = function() {
    $(this.rootElement).on('click', 'tbody td button.match-button', function() {
      var cellData = $('#entity-match-table').DataTable().cell({
	"row": $(this).closest('tr').index(),
	"column": $(this).closest('td').index()
      }).data();
      console.log(cellData);
    });
  };


  /**
   * Initalizes datatable and event handlers
   */
  EntityMatcher.prototype.init = function() {
    $(this.rootElement).DataTable(this.datatableOptions);
    this.buttonHandler();
  };
  
    
  return EntityMatcher;
}));
