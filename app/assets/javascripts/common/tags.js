(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'));
  } else {
    root.tags = factory(root.jQuery);
  }
}(this, function ($) {

  var TAGS = null;

  // Tags = { [id: string]: Tag }
  // Tag = type { name: string, description: string, id: number }
  
  /**
   * 
   * @param {Tags} all
   * @param {Array[number]} current
   *
   */
  function init(all, current){
    TAGS = { all: all, current: current };//parseInit(all, current);
    _render();
  }
  
  function add(tags, tag){}
  
  function remove(tags, tagId){}

  function _render(tags){}

  function get() {
    return TAGS;
  }
  
  return {
    get: get,
    init: init
  };

})());


 /*
   Entity.tags = x
 */
 
