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

  var ids = {
    uploadButton:  "bulk-add-upload-button",
    notifications: "bulk-add-notifications"
  };

  self.init = function(args){
    // TODO: (ag|18-Oct-2017)
    // It would be nice to parameterize here:
    //   1. resource type
    //   2. columns by resource typeself.
    // so table could be reused for any resource (not just entities)
    state = Object.assign(state, {
      // derrived
      rootId:         args.rootId,
      endpoint:       args.endpoint || "/",
      resource:       args.resource || "entities", //TODO: remove
      title:          args.title || "Bulk add", //TODO: extract to rails view
      // TODO: extract next 3 fields into `entities sub-field`
      entitiesById:   args.entitiesById || {},
      rowIds:         Object.keys(args.entitiesById || {}),
      matches:        {},
      // TODO: ---^
      // deterministic
      canUpload:      true,
      notification:   ""
    });
    self.render();
    detectUploadSupport();
  };

  // getters

  self.get = function(attr){
    return util.getProperty(state, attr);
  };

  state.hasRows = function(){
    return !util.isEmpty(state.rowIds);
  };

  state.hasMatches = function(entity){
    return !util.isEmpty(
      util.getProperty(state.matches, entity.id) || []
    );
  };

  // setters

  // Entity -> Entity
  state.addEntity = function(entity){
    util.setProperty(state.entitiesById, entity.id, entity);
    state.rowIds.push(entity.id);
    return entity;
  };

  // Entity -> Entity
  state.assignId = function(entity, idx){
    return Object.assign(entity, { id: "newEntity" + idx });
  };

  // [Entity] -> Promise[Void]
  state.matchEntities = function(entities){
    return Promise.all(entities.map(state.matchEntity));
  };

  // Entity -> Promise[Void]
  state.matchEntity = function(entity){
    return api.searchEntity(entity.name)
      .then(function(matches){
        util.setProperty(state.matches, entity.id, matches);
      });
  };

  state.disableUpload = function(){
    state.canUpload = false;
  };

  state.setNotification = function(msg){
    state.notification = msg;
  };

  // ENVIRONMENT DETECTION

  function detectUploadSupport(){
    if (!util.browserCanOpenFiles()) {
      state.disableUpload();
      state.setNotification('Your browser does not support uploading files to this page.');
      self.render();
    }
  }

  // FILE HANDLING

  function handleUploadThen(processFile, caller){
    if (self.hasFile(caller)) {
      var reader = new FileReader();
      reader.onloadend = function() {  // triggered when file is finished being read
        reader.result ? processFile(reader.result): console.error('Error reading csv');
      };
      reader.readAsText(self.getFile(caller)); // start reading (will trigger `onloadend` when done)
    }
  };

  // String -> Promise[Void]
  function ingestEntities (csv){
    const entities = Papa
          .parse(csv, { header: true, skipEmptyLines: true})
          .data
          .map(state.assignId)
          .map(state.addEntity);
    return state.matchEntities(entities)
      .then(state.disableUpload)
      .then(self.render);
  };

  // expose below 2 functions for testing  seams
  // (cannot mutate caller.files for security reasons)
  
  self.hasFile = function(caller){
    return Boolean(caller.files[0]);
  };

  self.getFile = function(caller){
    return caller.files[0];
  };

  // RENDERING

  self.render = function(){
    $('#' + state.rootId).empty();
    $('#' + state.rootId)
      .append(header())
      .append(notifications())
      .append(state.canUpload ? uploadContainer() : null)
      .append(state.hasRows()? table() : null);
  };

  function header(){
    return $('<h1>', { text: state.title });
  }

  function notifications(){
    return $('<div>', {
      id: ids.notifications,
      text: state.notification
    });
  };

  function uploadContainer(){
    return $('<div>', {id: 'bulk-add-upload-container'})
      .append(uploadButton());
  }

  function uploadButton(){
    return $('<label>', {
      class: 'btn btn-primary btn-file',
      text: 'Upload CSV'
    }).append(
      $('<input>', {
        id:    ids.uploadButton,
        type:  "file",
        style: "display:none",
        change: function() { handleUploadThen(ingestEntities, this); }
      })
    );
  }

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
        var entity = util.getProperty(state.entitiesById, id);
        return $('<tr>').append(
          columns.map(function(col, idx){
            return $('<td>', {
              text: util.getProperty(entity, col.attr)
            }).append(
              maybeDupeWarning(entity, col, idx)
            );
          })
        );
      })
    );
  }

  function maybeDupeWarning(entity, col, idx) {
    return idx == 0 && state.hasMatches(entity) && dupeWarningPopup(entity);
  }

  function dupeWarningPopup(entity) {
    return $('<div>', {
      class:           'dupe-warning',
      cursor:          'pointer',
      title:           'Data duplication warning:',
      'data-toggle':   'popover',
      'data-content':  dupeWarning(entity)
    })
      .append($('<div>', { class: 'alert-icon' }))
      .popover();
  }

  function dupeWarning(entity) {
    return "An entity named " + entity.name + " already exists in LittleSis. " +
      "Are you sure you want to add " + entity.name + "?";
  };

  // MISC

  // expose ingestEntities as testing seam for post-upload logic
  // (we want to act as though the csv has already uploaded w/o having to mock file-level browser behavior)
  self.ingestEntities = ingestEntities;

  // RETURN
  return self;
}));
