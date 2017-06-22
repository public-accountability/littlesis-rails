/**
 * politicalOrg: Political Org tab showing the donations of 
 * people who hold positions at the organization
 *
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'), require('../common/utility'));
  } else {
    // Browser globals (root is window)
    root.politicalOrg = factory(root.jQuery, root.utility);
  }
}(this, function ($, utility) {


  return {};
}));
