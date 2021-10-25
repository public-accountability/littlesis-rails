(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jquery'), require('../common/utility'));
  } else {
    root.api = factory(root.jQuery, root.utility);
  }
}(this, function ($, util) {

  // API
  var self = {};

  // Object -> Promise[[Entity]]
  self.searchEntity = function(query){
    return get('/search/entity', { num: 10, q: query })
      .then(format)
      .catch(handleError);

    // [Entity] -> [Entity]
    function format(results){
      // stringify id & rename keys (`primary_type` -> `primary_ext`; `description` -> `blurb`)
      return results.map(function(result) {
        var _result = Object.assign({}, result, {
          primary_ext: result.primary_ext || result.primary_type,
          blurb:       result.blurb || result.description,
          id:          String(result.id)
        });
        delete _result.primary_type;
        delete _result.description;
        return _result;
      });
    }

    // Error -> []
    function handleError(err){
      console.error('API request error: ', err);
      return [];
    }
  };

  // [EntityWithoutId] -> Promise[[Entity]]
  self.createEntities = function(entities){
    return post('/entities/bulk', formatReq(entities))
      .then(formatResp);

    // [Entity] -> [Entity]
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

    // [Entity] -> [Entity]
    function formatResp(resp){
      // copy, but stringify id
      return resp.data.map(function(datum){
        return Object.assign(
          datum.attributes,
          { id: String(datum.attributes.id)}
        );
      });
    }
  };

  // Integer, [Integer] -> Promise[[ListEntity]]
  self.addEntitiesToList = function(listId, entityIds, reference){
    return post('/lists/'+listId+'/entities/bulk', formatReq(entityIds))
      .then(formatResp);

    function formatReq(entityIds){

      return {
        data: entityIds.map(function(id){
          return { type: 'entities', id: id };
        }).concat({
          type: 'references',
          attributes: reference
        })
      };
    };

    function formatResp(resp){
      return resp.data.map(function(datum){
        return util.stringifyValues(datum.attributes);
      });
    }
  };

  // String, Integer -> Promise


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

  function patch(url, payload){
    return fetch(url, {
      headers:     headers(),
      method:      'PATCH',
      credentials: 'include', // use auth tokens stored in session cookies
      body:        JSON.stringify(payload)
    }).then(function(response) {
      if (response.body) {
	return jsonify(response);
      } else {
	return response;
      }
    });
  };

  function headers(){
    return {
      'Accept':       'application/json, text/plain, */*',
      'Content-Type': 'application/json',
      'Littlesis-Request-Type': 'API',
       // TODO: retrieve this w/o JQuery
      'X-CSRF-Token': $("meta[name='csrf-token']").attr("content") || ""
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

  return self;
}));
