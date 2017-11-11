(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'), require('../common/utility'));
  } else {
    root.api = factory(root.jQuery, root.utility);
  }
}(this, function ($, util) {

  // API
  var self = {};

  self.searchEntity = function(query){
    return get('/search/entity', { num: 10, no_summary: true, q: query })
      .then(format)
      .catch(handleError);

    function format(results){
      // TODO: gracefully handle correctly named fields
      return results.reduce(function(acc, res) {
        var _res = Object.assign({}, res, {
          primary_ext: res.primary_type,
          blurb:       res.description,
          id:          String(res.id)
        });
        delete _res.primary_type;
        delete _res.description;
        return acc.concat([_res]);
      },[]);
    }

    function handleError(err){
      console.error('API request error: ', err);
      return [];
    }
  };

  self.getEntity = function(id){
    return get('/entities/' + id, {}).then(res => res.data.attributes);
  };

  // helpers

  function get(url, queryParams){
    return fetch(url + '.json?' + qs(queryParams), { credentials: 'include' })
      .then(jsonify);
  }

  function qs(queryParams){
    return $.param(queryParams);
  }

  function jsonify(response){
    return response.json();
  }

  return self;
}));
