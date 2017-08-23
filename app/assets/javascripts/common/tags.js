(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'));
  } else {
    root.tags = factory(root.jQuery);
  }
}(this, function ($) {

  var LIST_ID = "tags-edit-list";
  var TAGS = null;
  var t = {};

  // type Tags = { [all: string]: TagsById, [current: string]: Array<number>, divs: Divs}
  // type TagsById = { [id: string]: Tag }
  // type Divs = { [id: string]: string }
  // type Tag = type { name: string, description: string, id: number }
  
  /**
   * Initalization of widget 
   * @param {Array[Tag]} tags
   * @param {Array[number]} current
   * @param {Object} divs
   * @return {Tags}
   *
   */
  t.init = function(tags, current, divs){
    TAGS = {
      all: tags.reduce(
    	function(acc, tag){
          return Object.assign(acc, { [tag.id]: tag });
        }, {}
      ),
      current: current,
      divs: divs,
      cache: $(divs.container).html()
    };
    // handle edit click
    $(divs.edit).click(function(){ t.render(); });
    return TAGS;
  };

  // mutate store
  t.update = function(action, id){
    t[action](id);
    t.render(TAGS);
    t.post(TAGS);
  };

  t.add = function(id) {
    TAGS.current = TAGS.current.concat(id);
  };
  
  t.remove = function(idToRemove){
    TAGS.current = TAGS.current.filter(function(id){
      return id !== idToRemove;
    });
  };

  // update done
  t.render = function(){
    $(TAGS.divs.container)
      .empty()
      .append(tagList());
  };

  function tagList(){
    return $('<ul>', {id: LIST_ID})
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

  // getter
  t.get = function() {
    return TAGS;
  };
  
  
  return t;
  
}));

 /*
   Entity.tags = x
 */
 
