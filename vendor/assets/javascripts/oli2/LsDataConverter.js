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
          is_directional: r.is_directional === true,
          is_current: r.is_current === true,
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

window.LsDataConverter = LsDataConverter;
module.exports = LsDataConverter;
