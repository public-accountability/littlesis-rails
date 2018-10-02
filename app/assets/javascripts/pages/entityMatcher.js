(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'), require('../common/utility'));
  } else {
    root.EntityMatcherTable = factory(root.jQuery, root.utility);
  }
}(this, function ($, util) {


  /**
   * Configurable table for matching a dataset
   * to LittleSis Entities
   * 
   * @param {Object} config
   */
  function EntityMatcherTable(config) {
    this.config = config;
  }


  return EntityMatcherTable;
}));
