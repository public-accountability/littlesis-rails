"use strict";

(function() {
  var root = this;
  var previous_LsDataSource = root.LsDataSource;

  var toQueryString = function(obj) {
    var parts = [];

    for (var i in obj) {
      if (obj.hasOwnProperty(i)) {
        if (Array.isArray(obj[i])) {
          obj[i].forEach(function(val) {
            parts.push(encodeURIComponent(i+"[]") + "=" + encodeURIComponent(val));
          });
        } else {
          parts.push(encodeURIComponent(i) + "=" + encodeURIComponent(obj[i]));
        }
      }
    }

    return parts.join("&");
  }

  var get = function(url, data, onSucess, onFail) {
    var httpRequest = new XMLHttpRequest();

    if (!httpRequest) {
      alert('Giving up :( Cannot create an XMLHTTP instance');
      return false;
    }

    httpRequest.onreadystatechange = function() {
      if (httpRequest.readyState === XMLHttpRequest.DONE) {
        if (httpRequest.status === 200) {
          onSucess(JSON.parse(httpRequest.responseText));
        } else {
          if (onFail) {
            onFail({ status: httpRequest.status, error: httpRequest.responseText });
          }
        }
      }
    };

    var fullUrl = url + (data ? "?" + toQueryString(data) : "")

    httpRequest.open('GET', fullUrl);
    httpRequest.send();
  };

  var LsDataSource = {
    name: 'LittleSis',
    baseUrl: 'http://lilsis.local',

    findNodes: function(text, callback) {
      get(
        this.baseUrl + '/maps/find_nodes', 
        { num: 12, desc: true, with_ids: true, q: text },
        callback
      );
    },

    getNodeWithEdges: function(nodeId, nodeIds, callback) {
      get(
        this.baseUrl + '/maps/node_with_edges',
        { node_id: nodeId, node_ids: nodeIds },
        callback
      );
    },

    getConnectedNodesOptions: {
      category_id: {
        1: "Position",
        2: "Education",
        3: "Membership",
        4: "Family",
        5: "Donation",
        6: "Transaction",
        7: "Lobbying",
        8: "Social",
        9: "Professional",
        10: "Ownership",
        11: "Hierarchy",
        12: "Generic"
      }
    },

    getConnectedNodes: function(nodeId, nodeIds, options, callback) {
      options.node_id = nodeId;
      options.node_ids = nodeIds;
      
      get(
        this.baseUrl + '/maps/edges_with_nodes',
        options,
        callback
      );
    }
  };

  LsDataSource.noConflict = function() {
    root.LsDataSource = previous_LsDataSource;
    return LsDataSource;
  }

  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = LsDataSource;
    }

    exports.LsDataSource = LsDataSource;
  } 
  else {
    root.LsDataSource = LsDataSource;
  }

}).call(this);