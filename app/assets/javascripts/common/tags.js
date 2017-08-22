(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'));
  } else {
    root.tags = factory(root.jQuery);
  }
}(this, function ($) {

  var TAGS = null;
  var t = {};

  // Tags = { [id: string]: Tag }
  // Tag = type { name: string, description: string, id: number }
  t.add = function(id) {
    TAGS.current = TAGS.current.concat(id);
  };
  
  /**
   * 
   * @param {Tags} all
   * @param {Array[number]} current
   *
   */
  t.init = function(all, current){
    TAGS = {
      all: all.reduce(
    	function(acc, tag){ return Object.assign(acc, { [tag.id]: tag }); },
    	{}
      ),
      current: current
    };//parseInit(all, current);
    return TAGS;
  };

  t.update = function(action, id){
    t[action](id);
    t.render(TAGS);
    t.post(TAGS);
  };

  t.render = function(){}; // update dom
  t.post = function(){}; // update server
  
  t.remove = function(idToRemove){
    TAGS.current = TAGS.current.filter(function(id){
      return id !== idToRemove;
    });
  };

  t.get = function() {
    return TAGS;
  };
  
  
  return t;
  
}));

 /*
   Entity.tags = x
 */
 
