(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'), require('../common/utility'));
  } else {
    root.api = factory(root.jQuery, root.utility);
  }
}(this, function ($, util) {

  var self = {};

  self.searchEntity = function(query){
    return $.getJSON('/search/entity', {
      num: 10,
      q: query,
      no_summary: true
    })
      .then(function(res) { return format(res); })
      .catch(function(err){ return []; });

    function format(results){
      return results.reduce(function(acc, res) {
        // replace `primary_type` key w/ `primary_ext` key`
        var _res = Object.assign({}, res, { primary_ext: res.primary_type });
        delete _res.primary_type;
        return acc.concat([_res]);
      },[]);
    }
  };

  return self;
}));
