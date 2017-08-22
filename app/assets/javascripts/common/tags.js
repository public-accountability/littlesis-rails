(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'));
  } else {
    root.tags = factory(root.jQuery);
  }
}(this, function ($) {

  var TAGS = null;
  var DIV = null;
  var t = {};

  // Tags = { [id: string]: Tag }
  // Tag = type { name: string, description: string, id: number }
  t.add = function(id) {
    TAGS.current = TAGS.current.concat(id);
  };
  
  /**
   * 
   * @param {Tags} tags
   * @param {Array[number]} current
   * @param {String} divId
   * @return {Tags}
   *
   */
  t.init = function(tags, current, divId){
    TAGS = {
      all: tags.reduce(
    	function(acc, tag){ return Object.assign(acc, { [tag.id]: tag }); },
    	{}
      ),
      current: current
    };//parseInit(all, current);
    DIV = divId;
    return TAGS;
  };

  t.update = function(action, id){
    t[action](id);
    t.render(TAGS);
    t.post(TAGS);
  };

  // update dom
  t.render = function(){
    $(DIV)
      .empty()
      .append(tagList());
  };

  function tagList(){
    return $('<ul>', {id: 'tag-list'})
      .append(TAGS.current.map(tagButton));
  }
  
  function tagButton(id){
    return $('<li>', {
      class: 'tag',
      text: TAGS.all[id].name
    }).append(removeButton(id));
  }

  function removeButton(id) {
    return $('<span>', {
      class: 'tag-remove-button',
      click: function(){
	t.update('remove', id);
      }
    });
  }
  
 // update server
  t.post = function(){};
  
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
 
