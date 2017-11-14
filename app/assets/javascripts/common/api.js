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
      return results.reduce(function(acc, res) {
        var _res = Object.assign({}, res, {
          primary_ext: res.primary_ext || res.primary_type,
          blurb:       res.blubr || res.description,
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

  // [EntityWithoutId] -> Promise[[Entity]]
  self.createEntities = function(entities){
    return post('/entities/bulk', formatReq(entities))
      .then(formatResp);

    function formatReq(entities){
      return {
        data: entities.map(function(entity){
          return {
            type: "entities",
            attributes: entity
          };
        })
      };
    };

    function formatResp(resp){
      return resp.data.map(function(datum){
        return Object.assign(
          datum.attributes,
          { id: String(datum.attributes.id)}
        );
      });
    }
  };

  // Integer, [Integer] -> Promise[[ListEntity]]
  self.addEntitiesToList = function(listId, entityIds){
    return post('/lists/'+listId+'/associations/entities', formatReq(entityIds))
      .then(formatResp);

    function formatReq(entityIds){
      return {
        data: entityIds.map(function(id){
          return { type: 'entities', id: id };
        })
      };
    };

    function formatResp(resp){
      return resp.data.map(function(datum){
        return util.stringifyValues(datum.attributes);
      });
    }
  };

  // helpers

  function get(url, queryParams){
    return fetch(url + qs(queryParams), {
      headers:      headers(),
      method:      'get',
      credentials: 'include' // use auth tokens stored in session cookies
    }).then(jsonify);
  }

  function post(url, payload){
    return fetch(url, {
      headers:     headers(),
      method:      'post',
      credentials: 'include', // use auth tokens stored in session cookies
      body:        JSON.stringify(payload)
    }).then(jsonify);
  };

  function headers(){
    return {
      'Accept':       'application/json, text/plain, */*',
      'Content-Type': 'application/json',
      'X-CSRF-Token': getAuthToken()
    };
  }

  function qs(queryParams){
    return '?' + $.param(queryParams);
  }

  // Response -> Promise[Error|JSON]
  function jsonify(response){
    return response
      .json()
      .then(function(json){
        return json.errors ?
          Promise.reject(json.errors[0].title) :
          Promise.resolve(json);
      });
  }

  function getAuthToken(){
    // as per: https://stackoverflow.com/questions/7785079/how-use-token-authentication-with-rails-devise-and-backbone-js#answer-18861372
    // TODO: figure out how to do this without jQuery
    return $("meta[name='csrf-token']").attr("content") || "";
  }
  
  return self;
}));
