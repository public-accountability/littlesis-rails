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
  var DEFAULT_OPTIONS = { isList: false };

  // Variables to hold fetched data and the entity initalized.
  // This is just a way to keep state without having to
  // deal with creating a javascript class
  var DATA_STORE = null;
  var ENTITY_ID = null;

  var DATATABLE_COLUMNS = [
    { 
      data: 'related_entity_name', 
      name: 'related_entity_name', 
      width: '40%',
      render: renderRelatedEntity
    },
    {
      data: 'category',
      name: 'category',
      width: "10%",
      render: renderCategory
    },
    {
      name: 'description',
      render: renderDescription
    },
    {
      data: 'date',
      name: 'date',
      width: "15%",
      render: renderDate
    }
  ];

  /**
   * Network request to obtain data for datatable
   *
   * @param {Integer} entityId
   * @returns {Promise} 
   */
  function fetchData(entityId) {
    return fetch("/datatable/entity/" + entityId, { "method": 'get' })
      .then(function(response) { return response.json(); });
  }

  /**
   * Returns the other entity id in the relationship
   *
   * @param {Object} relationship
   * @param {Object} other_entity_id
   */
  function otherEntity(relationship) {
    var entity_id = (relationship.entity1_id === ENTITY_ID) ? relationship.entity2_id : relationship.entity1_id;
    return DATA_STORE.entities[entity_id];
  };

  /////////////////////////////
  ///// RENDERING HELPERS /////
  /////////////////////////////

  /**
   * Render Link with Related Entity Names and Blurb
   * @returns {String} 
   */
  function renderRelatedEntity(_data, _type, row) {
    var entity = otherEntity(row);
    var a = utility.createLink(entity.url);
    a.setAttribute('class', 'entity-link');
    a.textContent = entity.name;
    
    if (entity.blurb) {
      // a.appendChild(createElement('br'));
      var blurb = utility.createElementWithText('div', entity.blurb);
      blurb.setAttribute('class', 'entity-blurb');
      a.appendChild(blurb);
    }
    
    return a.outerHTML;
  };


  /**
   * Renders description fields. Adds amount if present.
   *
   * @returns {String} 
   */
  function renderDescription(data, type, row) {
    if (ENTITY_ID === row.entity1_id) {
      return row.label_for_entity1;
    } else {
      return row.label_for_entity2;
    }
  };

  /**
   * Render link to Relationship
   *
   * @returns {String} 
   */
  function renderCategory(_data, _type, row) {
    var a = utility.createLink(row.url);
    a.textContent = utility.relationshipCategories[row.category_id];
    return a.outerHTML;
  };

  /**
   * Renders date or shows if relationship is current/past
   *
   * @returns {String|Null} 
   */
  function renderDate(data, type, row) {
    if (row.start_date && row.end_date) {
      if (row.start_date.slice(0, 4) === row.end_date.slice(0, 4)) {
	return row.start_date.slice(0, 4);
      } else {
	return row.start_date.slice(0, 4) + ' - ' + row.end_date.slice(0, 4);
      }
    }

    if (row.start_date && !row.end_date) {
      if (row.is_current === false) {
	return row.start_date.slice(0, 4) + ' (past)';
      } else {
	return row.start_date.slice(0, 4) + ' - ?';
      }
    }
    
    if (row.end_date) {
      return '? - ' + row.end_date.slice(0, 4);
    }

    if (row.is_current === true) {
      return "(current)";
    }

    if (row.is_current === false) {
      return "(past)";
    }
    return null;
  };


  /**
   * Creates a <table> with column headers
   *
   * @returns {Element} 
   */
  function createTable() {
    var table = createElement('table');
    table.className = "display";
    table.id = TABLE_ID;

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
  
  /**
   * Main function that initializes the table
   *
   * @param {Array[object]} data
   */
  function datatable() {
    $('#' + TABLE_ID).DataTable({
      "data": DATA_STORE.relationships,
      "dom": 'prtp',
      // dom: "<'buttons'>iprtp",
      "pageLength": 100,
      "columns": DATATABLE_COLUMNS
    });

  }

  function start(entityId) {
    ENTITY_ID = entityId;
    fetchData(entityId)
      .then(function(data) {
	DATA_STORE = data;
	insertTableIntoDom();
	datatable();
      });

  }

  return {
    "start": start,
    "data": function() { return DATA_STORE; }
  };
  
  
}));
