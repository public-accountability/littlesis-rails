(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'), require('../common/utility'));
  } else {
    root.bulkTable = factory(root.jQuery, root.utility);
  }
}(this, function ($, util) {

  var self = {}; // returned at bottom of file

  // STATE MANAGEMENT
  var state = {};

  // TODO: parameterize these!
  var columns = [{
    label: 'Name',
    attr:  'name',
    input: 'text'
  },{
    label: 'Entity Type',
    attr:  'primary_ext',
    input: 'select'
  },{
    label: 'Description',
    attr:  'blurb',
    input: 'text'
  }];

  self.init = function(args){
    state = {
      // TODO: (ag|18-Oct-2017)
      // It would be nice to parameterize here:
      //   1. resource type
      //   2. columns by resource type
      // so table could be reused for any resource (not just entities)
      rootId:         args.rootId,
      resource:       args.resource || "entities",
      entitiesById:   args.entitiesById || {},
      rowIds:         Object.keys(args.entitiesById || {}),
      uploadButtonId: args.uploadButtonId,
      endpoint:       args.endpoint || "/",
      title:          args.title || "Bulk add"
    };
    registerEventHandlers();
    self.render();
  };

  self.get = function(attr){
    return util.getProperty(state, attr);
  };

  function hasRows(){
    return !util.isEmpty(state.rowIds);
  }

  function addEntity(entity){
    util.setProperty(state.entitiesById, entity.id, entity);
    state.rowIds.push(entity.id);
  };

  // EVENT HANLDERS

  function registerEventHandlers(){
    !util.browserCanOpenFiles() ?
      replaceUploadButton() :
      self.onUpload(self.ingestEntities);
  }

  // FILE HANDLING

  self.onUpload = function(handleUpload){
    $("#" + state.uploadButtonId).change(function(){
      if (self.hasFile(this)) {
    	var reader = new FileReader();
	reader.onloadend = function() {  // triggered when file is finished being read
          reader.result ? handleUpload(reader.result): console.error('Error reading csv');
	};
	reader.readAsText(self.getFile(this)); // start reading (will trigger `onloadend` when done)
      }
    });
  };

  self.ingestEntities = function(csv){
    const entities = Papa.parse(csv, { header: true, skipEmptyLines: true}).data;
    entities.forEach((e,idx) => addEntity(Object.assign(e, { id: "newEntity"+idx })));
    self.render();
  };

  self.hasFile = function(caller){
    return Boolean(caller.files[0]);
  };

  self.getFile = function(caller){
    return caller.files[0];
  };

  // RENDERING

  self.render = function(){
    if(hasRows()){
      $('#'+state.rootId).append(table());
    }
  };

  function table(){
    return $('<table>', { id: 'bulk-add-table'})
      .append(thead())
      .append(tbody());
  };

  function thead(){
    return $('<thead>').append(
      $('<tr>').append(
        columns.map(function(c) {
          return $('<th>', {
            text: c.label
          });
        })
      )
    );
  }

  function tbody(){
    return $('<tbody>').append(
      state.rowIds.map(function(id){
        var entity = state.entitiesById[id];
        return $('<tr>').append(
          columns.map(function(c){
            return $('<td>', {
              text: entity[c.attr]
            });
          })
        );
      })
    );
  }

  // MISC

  function replaceUploadButton(){
    $('#'+state.uploadButtonId).replaceWith(
      $('<div>', {
        id: 'new-entities-cant-upload-msg',
        text: 'Sorry! Your browser does not support uploading files.'
      })
    );
  }

  // RETURN
  return self;
}));
