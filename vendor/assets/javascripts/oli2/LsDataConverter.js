"use strict";

(function() {
  var root = this;
  var previous_LsDataConverter = root.LsDataConverter;

  var LsDataConverter = {
    convertUrl: function(url) {
      return url ? (url.match(/littlesis\.org/) ? url : "//littlesis.org" + url) : null;
    },

    convertEntity: function(e) {
      return {
        id: e.id,
        display: { 
          name: e.name,
          x: e.x,
          y: e.y,
          scale: e.scale ? e.scale : 1,
          status: e.status ? e.status : "normal",
          image: e.image,
          url: this.convertUrl(e.url)
        }    
      };
    },

    convertRel: function(r) {
      return {
        id: r.id,
        node1_id: r.entity1_id,
        node2_id: r.entity2_id,
        display: { 
          label: r.label,
          cx: r.x1,
          cy: r.y1,
          scale: r.scale ? r.scale : 1,
          arrow: r.is_directional,
          dash: r.is_current,
          status: r.status ? r.status : "normal",
          url: this.convertUrl(r.url)
        }
      };
    },

    convertText: function(t, id) {
      return {
        id: id,
        display: { 
          text: t.text, 
          x: t.x, 
          y: t.y 
        }
      };
    },

    convertMapData: function(data) {
      var that = this;

      var nodes =  data.entities.reduce(function(result, e) {
        result[e.id] = that.convertEntity(e);
        return result;
      }, {});

      var edges = data.rels.reduce(function(result, r) {
        result[r.id] = that.convertRel(r);
        return result;
      }, {});

      var captions = data.texts.reduce(function(result, t, i) {
        result[i+1] = that.convertText(t, i+1);
        return result;
      }, {});

      return {
        id: data.id,
        title: data.title,
        description: data.description,
        nodes: nodes,
        edges: edges,
        captions: captions
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