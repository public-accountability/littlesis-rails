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


  /**
   * Render Link with Related Entity Names and Blurb
   * @returns {String} 
   */
  function renderRelatedEntity(data, type, row) {
    var a = utility.createLink(row.related_entity_url);
    a.setAttribute('class', 'entity-link');
    a.textContent = row.related_entity_name;;
    
    if (row.related_entity_blurb_excerpt) {
      var blurb = utility.createElementWithText('span', row.related_entity_blurb_excerpt);
      blurb.setAttribute('class', 'entity-blurb');
      a.appendChild(blurb);
    }
    
    return a.outerHTML;
  }
  
  function renderCategory(data, type, row) {
    var a = utility.createLink(row.url);
    a.textContent = row.category;
    return a.outerHTML;
  }

  function datatable(data) {
    $('#' + TABLE_ID).DataTable({
      data: data,
      // dom: "<'buttons'>iprtp",
      pageLength: 100,
      columns: [
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
	  data: 'description',
          name: 'details'
	},
	{
	  data: 'date',
	  name: 'date'
	}
      ]

    });

  }

  function insertTableIntoDom() {
    document
      .getElementById('relationships-datatable-container')
      .appendChild(createTable());
  }


  function start() {
    insertTableIntoDom();

    var data = JSON.parse("[{\"id\":30,\"url\":\"/relationships/30\",\"entity_id\":2,\"entity_name\":\"ExxonMobil\",\"entity_url\":\"/entities/2-ExxonMobil/datatable\",\"related_entity_id\":1030,\"related_entity_name\":\"Donald D Humphreys\",\"related_entity_blurb\":null,\"related_entity_blurb_excerpt\":\"testing testing 1 2 3\",\"related_entity_url\":\"/entities/1030-Donald_D_Humphreys/datatable\",\"related_entity_types\":\"Person,Business Person\",\"related_entity_industries\":\"Oil & Gas\",\"category\":\"Position\",\"description\":\"Senior Vice President\",\"date\":\"\",\"is_current\":true,\"amount\":null,\"updated_at\":\"2008-11-05T17:05:50.000Z\",\"is_board\":false,\"is_executive\":true,\"start_date\":null,\"end_date\":null,\"interlock_ids\":\"\",\"list_ids\":\"\"},{\"id\":31,\"url\":\"/relationships/31\",\"entity_id\":2,\"entity_name\":\"ExxonMobil\",\"entity_url\":\"/entities/2-ExxonMobil/datatable\",\"related_entity_id\":1030,\"related_entity_name\":\"Donald D Humphreys\",\"related_entity_blurb\":\"just some rich guy\",\"related_entity_blurb_excerpt\":null,\"related_entity_url\":\"/entities/1030-Donald_D_Humphreys/datatable\",\"related_entity_types\":\"Person,Business Person\",\"related_entity_industries\":\"Oil & Gas\",\"category\":\"Position\",\"description\":\"Treasurer\",\"date\":\"\",\"is_current\":true,\"amount\":null,\"updated_at\":\"2008-11-05T17:05:50.000Z\",\"is_board\":false,\"is_executive\":true,\"start_date\":null,\"end_date\":null,\"interlock_ids\":\"\",\"list_ids\":\"\"}]");

    datatable(data);
  }

  return {
    "start": start,
    "_createTable": createTable,
    "_columns": columns,
    "_renderRelatedEntity": renderRelatedEntity
  };

}));
