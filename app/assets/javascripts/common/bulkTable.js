(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'));
  } else {
    root.bulkTable = factory(root.jQuery);
  }
}(this, function ($) {

  var self = {}; // returned at bottom of file

  // STORE MUTATION
  var state = {};

  self.init = function(args){
    state = {
      entitiesById:   args.entitiesById || {},
      rootId:         args.rootId,
      uploadButtonId: args.uploadButtonId
    };
    self.onUpload(state.uploadButtonId, self.parseEntities);
  };

  self.get = function(attr){
    return getProperty(state, attr);
  };

  // FILE HANDLING

  self.onUpload = function(uploadButtonId, handleUpload){
    // TODO:  handle browser that can't open files
    $("#" + uploadButtonId).change(function(){
      if (self.hasFile()) {
    	var reader = new FileReader();
	reader.onloadend = function() {  // triggered when file is finished being read
          reader.result ? handleUpload(reader.result): console.error('Error reading csv');
	};
	reader.readAsText(self.getFile()); // start reading (will trigger `onloadend` when done)
      }
    });
  };

  self.parseEntities = function(csv){
    const rows = Papa.parse(csv, { header: true, skipEmptyLines: true}).data;
    state.entitiesById = rows.reduce(function(acc, row, idx){
      return setProperty(acc, "newEntity" + idx, row);
    }, {});
  };

  self.hasFile = function(caller){
    return Boolean(caller.files[0]);
  };

  self.getFile = function(caller){
    return caller.files[0];
  };

  // UTILITY

  // TODO: extract
  function getProperty(obj, key) {
    return Object.getOwnPropertyDescriptor(obj, key).value;
  }

  // TODO: exract this mouthful!!! bet we don't want to write it ANYWHERE ELSE!!!!!!
  function setProperty(obj, key, value){
    return Object.defineProperty(obj, key, {
      configurable: true,
      enumerable: true,
      writeable: true,
      value: value
    });
  }

  // RETURN
  return self;
}));
