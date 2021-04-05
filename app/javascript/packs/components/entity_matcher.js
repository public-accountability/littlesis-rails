import utility from '../common/utility'
import datatable from 'datatables.net'

var matchExistsAndIsDisplay = function(row, type) {
  return row.entity_matches && row.entity_matches.length > 0 && type === 'display'
}

var entityLink = function(entityData) {
  return utility.createLink(
      utility.entityLink(entityData[0].id, entityData[0].name, entityData[0].primary_ext),
      entityData[0].name
      ).outerHTML 
}

// span w/ class "cycle-entity-match-arrow"
var rightArrow = function() {
  return '<span class="glyphicon glyphicon-triangle-right cycle-entity-match-arrow" aria-hidden="true"></span>'
}

/**
 * Takes a datatables row and returns an object with two keys: entity_id, id
 * 
 * @param {Object} row
 * @returns {Object} params
 */
var rowToParams = function(row) {
  if (!row.entity_matches || row.entity_matches.length === 0) {
    throw "no matched entities"
  }

  return {
    "entity_id": row.entity_matches[0].id,
    "id": row.id
  }
}

// --------------------------------------------------------------- //

/**
 * Rendering functions (static functions)
 */
var renders = {
  "entityMatch": function(data, type, row) {

    if (matchExistsAndIsDisplay(row, type)) {
      var link = entityLink(data)
      if (row.entity_matches.length > 1) {
        return link + rightArrow()
      } else {
        return link
      }
    }

    return ''
  },

  "matchButtons": function(data, type, row) {
    if (matchExistsAndIsDisplay(row, type)) {
      return utility.createElement({
        "tag": 'button',
        "text": "Match this row",
        "class": 'match-button'
      }).outerHTML
    } else {
      return ''
    }
  },

  "successfulMatch": function() {
    return '<b>Matched!</b>'
  },

  "errorMatch": function() {
    return '<b class="bg-warn">Errored</b>'
  }

}


/**
 * Configuration Variables
 */

var matchedEntityColumns = [
{ "data": 'entity_matches', "name": 'entity_matches', "title": 'Matched Entity', "render": renders.entityMatch },
{ "data": null, "name": 'match_buttons', "title": 'Match this row', "render": renders.matchButtons }
]

var baseDatatableOptions = { "processing": true, "serverSide": true, "ordering": false }

/**
 * Configurable table for matching a dataset
 * to LittleSis Entities
 *
 * @param {Object} config
 */
export default function EntityMatcher(config) {
  ['matchUrl', 'endpoint', 'columns'].forEach(function(requiredConfig) {
    if (typeof config[requiredConfig] === 'undefined') {
      throw "EntityMatcher() is missing a required configuration: " + requiredConfig
    }
  })

  this.config = config
  this.rootElement = config.rootElement || '#entity-match-table'
  this.endpoint = config.endpoint
  this.matchUrl = config.matchUrl
  this.columns = config.columns.concat(matchedEntityColumns)
  this.datatableOptions = Object.assign({},
      baseDatatableOptions,
      { "ajax": this.endpoint, "columns": this.columns })
}

/**
 * Returns a copy of the Datatable instance
 * @returns {DataTable} 
 */
EntityMatcher.prototype.table = function() {
  return $(this.rootElement).DataTable()
}


/**
 * Gets or set cell data
 * @param {Element} element
 * @param {Anything} newData
 * @returns {} 
 */
EntityMatcher.prototype.cellData = function(element, newData) {
  return this.table()
    .cell($(element).closest('td'))
    .data(newData)
}


/**
 * Data for row at given index
 * @param {Integer} rowIndex
 * @returns {Object} 
 */
EntityMatcher.prototype.rowData = function(rowIndex) {
  return this.table().row(rowIndex).data()
}

/**
 * Return <td> for the given column name and row index
 * @param {String} columnName
 *` @param {Integer} rowIndex
 * @returns {Element}
 */
EntityMatcher.prototype.cellNode = function(columnName, rowIndex) {
  return this.table()
    .column(columnName + ':name')
    .nodes()[rowIndex]
}


/**
 *  Replaces match button with "matched" html
 * @param {integer} rowIndex
 */
EntityMatcher.prototype.successfulMatch = function(rowIndex) {
  $(this.cellNode('match_buttons', rowIndex))
    .html(renders.successfulMatch())
}

/**
 *  Replaces match button with "errored" html
 * @param {integer} rowIndex
 */

EntityMatcher.prototype.errorMatch = function(rowIndex) {
  $(this.cellNode('match_buttons', rowIndex))
    .html(renders.errorMatch())
}


/**
 * Submits ajax request for for the current row
 *
 * @param {Object} Params
 * @returns {$.ajax}
 */
EntityMatcher.prototype.matchAjax = function(params) {
  return $.ajax({
    "url": this.matchUrl,
    "type": 'POST',
    "contentType": 'application/json',
    "data": JSON.stringify(params)
  })
}


/**
 * Performs entity matching
 * @param {Integer} rowIndex
 */
EntityMatcher.prototype.doMatch = function(rowIndex) {
  console.log("Matching row", rowIndex)
  var self = this
  var params = rowToParams(this.rowData(rowIndex))

  this.matchAjax(params)
    .done(function() {
      self.successfulMatch(rowIndex)
    })
  .fail(function() {
    self.errorMatch(rowIndex)
  })
}


/**
 * Cycles through entity matches
 */
EntityMatcher.prototype.cycleEntityMatch = function(element) {
  var cellData = this.cellData(element).slice() // get current entity matches
  cellData.push(cellData.shift())  // cycle array
  this.cellData(element, cellData) // update cell data with new cycled array
}


/**
 * Handlers for arrow that cycles between entity matches
 */
EntityMatcher.prototype.cycleArrowHandler = function() {
  var self = this

  $(this.rootElement).on('click', 'tbody td span.cycle-entity-match-arrow', function() {
    self.cycleEntityMatch(this)
  })
}


/**
 * Handles clicking on <button class="match-button">
 */
EntityMatcher.prototype.matchButtonHandler = function() {
  var self = this

  $(this.rootElement).on('click', 'tbody td button.match-button ', function() {
    var rowIndex = self.table().row($(this).closest('tr')).index()
    self.doMatch(rowIndex)
  })
}


/**
 * Initalizes datatable and event handlers
 */
EntityMatcher.prototype.init = function() {
  $(this.rootElement).DataTable(this.datatableOptions)
  this.matchButtonHandler()
  this.cycleArrowHandler()
}
