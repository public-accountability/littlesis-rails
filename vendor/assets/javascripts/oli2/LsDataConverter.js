"use strict";

(function() {
  var root = this;
  var previous_LsDataConverter = root.LsDataConverter;

  var LsDataConverter = {
    convertUrl: function(url) {
      return url ? (url.match(/littlesis\.org/) ? url : "//littlesis.org" + url) : null;
    },

    convertMapData: function(data) {
      var that = this;

      var nodes =  data.entities.reduce(function(result, e) {
        result[e.id] = {
          id: e.id,
          display: { 
            name: e.name,
            x: e.x,
            y: e.y,
            scale: e.scale ? e.scale : 1,
            status: e.status ? e.status : "normal",
            image: e.image,
            url: that.convertUrl(e.url)
          }
        };

        return result;
      }, {});

      var edges = data.rels.reduce(function(result, r) {
        result[r.id] = {
          id: r.id,
          node1_id: r.entity1_id,
          node2_id: r.entity2_id,
          display: { 
            label: r.label,
            cx: r.x1,
            cy: r.y1,
            scale: r.scale ? r.scale : 1,
            arrow: r.is_directional === true,
            dash: r.is_current === true ? "5, 2": null,
            status: r.status ? r.status : "normal",
            url: that.convertUrl(r.url)
          }
        };

        return result;
      }, {});

      return {
        id: data.id,
        title: data.title,
        description: data.description,
        nodes: nodes,
        edges: edges,
        captions: {}
      };
    },

    convertMapCollectionData: function(data) {
      var that = this;

      return {
        id: data.id,
        title: data.title,
        graphs: data.maps.map(function(map) { 
          return that.convertMapData(map); 
        })
      };
    }
  }

  LsDataConverter.noConflict = function() {
    root.LsDataConverter = previous_LsDataConverter;
    return LsDataConverter;
  }

  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = LsDataConverter;
    }

    exports.LsDataConverter = LsDataConverter;
  } 
  else {
    root.LsDataConverter = LsDataConverter;
  }

}).call(this);