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

  // type Tags = { [all: string]: TagsById, [current: string]: Array<string>, divs: Divs}
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
      current: current.map(String),
      divs: divs,
      cache: $(divs.container).html()
    };
    // handle edit click
    $(divs.edit).click(function(){ t.render(); });
    return TAGS;
  };

  // str -> ?string
  function getId(name){
    return Object.keys(TAGS.all).filter(function(k){
      return TAGS.all[k].name === name;
    })[0];
  };

  // mutate store
  t.update = function(action, id){
    t[action](id);
    t.render();
    t.post();
  };

  // input: str
  t.add = function(id) {
    TAGS.current = TAGS.current.concat(String(id));
  };
  
  t.remove = function(idToRemove){
    TAGS.current = TAGS.current.filter(function(id){
      return id !== String(idToRemove);
    });
  };

  // update done
  t.render = function(){
    $(TAGS.divs.container)
      .empty()
      .append(input())
      .append(tagList());
  };

  function input(){
    return $('<textarea>', {
      id: 'tags-input',
      keypress: function(e) {
        if (e.keyCode === 13 ) {
          updateIfValid($(this).val());
        }
      }
    }).css('z-index', 1);
    
  }
  
  function updateIfValid(tagInput){
    var id = getId(tagInput);
    if (isValid(id)) t.update('add', id);
  }

  function isValid(id){
    return Boolean(id) &&
      !TAGS.current.includes(id);
  }
  
  function tagList(){
    return $('<ul>', {id: LIST_ID})
      .css('z-index', 0)
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
 
