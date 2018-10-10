(function (root, factory) {
  root.EntityMatcher = factory(root.jQuery, root.utility);
}(this, function ($, util) {

  // Helper functions ------------------------------------------//

  var matchExistsAndIsDisplay = function(row, type) {
    return row.entity_matches && row.entity_matches.length > 0 && type === 'display';
  };

  var entityLink = function(entityData) {
    return util.createLink(
      util.entityLink(entityData[0].id, entityData[0].name, entityData[0].primary_ext),
      entityData[0].name
    ).outerHTML; 
  };

  // span w/ class "cycle-entity-match-arrow"
  var rightArrow = function() {
    return '<span class="glyphicon glyphicon-triangle-right cycle-entity-match-arrow" aria-hidden="true"></span>';
  };

  // ---------------------------------------------------------- //

  /**
   * Rendering functions (static functions)
   */
  var renders = {
    "entityMatch": function(data, type, row, meta) {

      if (matchExistsAndIsDisplay(row, type)) {
	var link = entityLink(data);
	if (row.entity_matches.length > 1) {
	  return link + rightArrow();
	} else {
	  return link;
	}
      }

      return '';
    },

    "matchButtons": function(data, type, row, meta) {
      if (matchExistsAndIsDisplay(row, type)) {
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
    { "data": 'entity_matches', "title": 'Matched Entity', "render": renders.entityMatch },
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
   * Returns a copy of the Datatable instance
   * @returns {DataTable} 
   */
  EntityMatcher.prototype.table = function() {
    return $(this.rootElement).DataTable();
  };


  /**
   * Returns coordinates of encapsulating cell
   * 
   * @param {Element} element - any element inside of a <td> cell
   * @returns {Object} coodinatgse
   */
  EntityMatcher.prototype.cellCoordinates = function(element) {
    return {
      "row": $(element).closest('tr').index(),
      "column": $(element).closest('td').index()
    };
  };
  
  /**
   * Gets or set cell data
   * @param {Element} element
   * @param {Anything} newData
   * @returns {} 
   */
  EntityMatcher.prototype.cellData = function(element, newData) {
    return this.table()
      .cell(this.cellCoordinates(element))
      .data(newData);
  };

  
  /**
   * Submits ajax request to perform match on currently selected
   * entity match
   */
  EntityMatcher.prototype.matchAjax = function() {

  };


  /**
   * Cycles through entity matches
   */
  EntityMatcher.prototype.cycleEntityMatch = function(element) { 
    var cellData = this.cellData(element).slice(); // get current entity matches
    cellData.push(cellData.shift());  // cycle array
    this.cellData(element, cellData); // update cell data with new cycled array
  };
  

  /**
   * 
   */
  EntityMatcher.prototype.cycleArrowHandler = function() {
    var self = this;
    
    $(this.rootElement).on('click', 'tbody td span.cycle-entity-match-arrow', function() {
      self.cycleEntityMatch(this);
    });
  };


  /**
   * Handles clicking on <button class="match-button">
   */
  EntityMatcher.prototype.matchButtonHandler = function() {
    var self = this;

    $(this.rootElement).on('click', 'tbody td button.match-button ', function() {
      console.log(self.cellData(this).entity_matches[0]);
    });
  };


  /**
   * Initalizes datatable and event handlers
   */
  EntityMatcher.prototype.init = function() {
    $(this.rootElement).DataTable(this.datatableOptions);
    this.matchButtonHandler();
    this.cycleArrowHandler();
  };
  
    
  return EntityMatcher;
}));
