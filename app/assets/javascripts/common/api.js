(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'), require('../common/utility'));
  } else {
    root.api = factory(root.jQuery, root.utility);
  }
}(this, function ($, util) {

  // API
  var self = {};

  // TODO: polyfill `fetch` with: https://github.com/github/fetch

  self.searchEntity = function(query){
    return get('/search/entity', q({ num: 10, no_summary: true, q: query }))
      .then(format)
      .catch(handleError);

    function format(results){
      return results.reduce(function(acc, res) {
        var _res = Object.assign({}, res, { primary_ext: res.primary_type });
        delete _res.primary_type;
        return acc.concat([_res]);
      },[]);
    }

    function handleError(err){
      console.error('API request error: ', err);
      return [];
    }
  };

  // helpers

  function get(url, queryString){
    return fetch(url + '.json?' + queryString,{ credentials: 'include' })
      .then(jsonify);
  }

  function q(obj){
    return $.param(obj);
  }

  function jsonify(response){
    return response.json();
  }

  return self;
}));
