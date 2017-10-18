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

  self.init = function(args){
    state = {
      entitiesById:   args.entitiesById || {},
      rootId:         args.rootId,
      uploadButtonId: args.uploadButtonId
    };
    registerEventHandlers();
  };

  self.get = function(attr){
    return util.getProperty(state, attr);
  };

  // EVENT HANLDERS

  function registerEventHandlers(){
    util.browserCanOpenFiles() ?
      self.onUpload(state.uploadButtonId, self.parseEntities) :
      replaceUploadButton();
  }

  // FILE HANDLING

  self.onUpload = function(uploadButtonId, handleUpload){
    // TODO:  handle browser that can't open files
    $("#" + uploadButtonId).change(function(){
      if (self.hasFile(this)) {
    	var reader = new FileReader();
	reader.onloadend = function() {  // triggered when file is finished being read
          reader.result ? handleUpload(reader.result): console.error('Error reading csv');
	};
	reader.readAsText(self.getFile(this)); // start reading (will trigger `onloadend` when done)
      }
    });
  };

  self.parseEntities = function(csv){
    const rows = Papa.parse(csv, { header: true, skipEmptyLines: true}).data;
    state.entitiesById = rows.reduce(function(acc, row, idx){
      return util.setProperty(acc, "newEntity" + idx, row);
    }, {});
  };

  self.hasFile = function(caller){
    return Boolean(caller.files[0]);
  };

  self.getFile = function(caller){
    return caller.files[0];
  };

  // RENDERING

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
