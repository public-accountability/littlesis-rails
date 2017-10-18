(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'));
  } else {
    root.bulkTable = factory(root.jQuery);
  }
}(this, function ($) {

  var self = {}; // returned at bottom of file
  var state = {};

  self.init = function(args){
    state = {
      rootId: args.rootId || ''
    };
  };

  self.get = function(attr){
    return Object.getOwnPropertyDescriptor(state, attr).value;
  };

  return self;
}));
