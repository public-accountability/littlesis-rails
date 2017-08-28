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

  // STORE FUNCTIONS

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
  t.init = function(tags, current, endpoint, divs){
    TAGS = {
      all: tags.reduce(
    	function(acc, tag){
          return Object.assign(acc, { [tag.id]: tag });
        }, {}
      ),
      current: current.map(String),
      divs: divs,
      cache: {
        html: $(divs.container).html(),
        tags: current.map(String)
      },
      endpoint: endpoint
    };
    handleEditClick();
    return TAGS;
  };

  // getter
  t.get = function() {
    return TAGS;
  };

  // str -> ?string
  t.getId = function(name){
    return Object.keys(TAGS.all).filter(function(k){
      return TAGS.all[k].name === name;
    })[0];
  };

  t.available = function(){
    return Object.keys(TAGS.all).filter(function(id){
      return !TAGS.current.includes(id);
    });
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

  // RENDER FUNCTIONS

  function handleEditClick(){
    $(TAGS.divs.edit).click(function(){
      $(this).hide();
      renderControls();
      t.render();
    });
    
  }

  function renderControls(){
    $(TAGS.divs.control)
      .append(saveButton())
      .append(cancelButton());
  }

  function saveButton(){
    return $('<button>', {
      id: 'tags-save-button',
      text: 'save',
      click: function(){
        $.post(TAGS.endpoint, {tags: { ids: TAGS.current  }})
          .done(function(){ window.location.reload(true); });
      }
    });
  }

  function cancelButton(){
    return $('<button>', {
      id: 'tags-cancel-button',
      text: 'cancel',
      click: function(){
        // restore state
        $(TAGS.divs.container).html(TAGS.cache.html);
        TAGS.current = TAGS.cache.tags;
        $('#tags-save-button').remove();
        $('#tags-cancel-button').remove();
        $(TAGS.divs.edit).show();
      }
    });    
  }
  
  // update done
  t.render = function(){
    $(TAGS.divs.container)
      .empty()
      .append(tagList())
      .append(select());
    
    $('#tags-select').selectpicker(); // possible to move this into select()?
  };

  
  // select field
  function select(){
    return $('<select>', {
      class: 'selectpicker',
      id: 'tags-select',
      title: 'Pick a tag...',
      'data-live-search': true,
      
      on: {
        'changed.bs.select': function(e) {
          updateIfValid($(this).val());
        }
      }
    })
      .append(selectOptions());
  }

  function selectOptions(){
    return t.available().map(function(tagId){
      return $('<option>', {
        class: 'tags-select-option',
        text: TAGS.all[tagId].name
      });
    });
  };
  
  function updateIfValid(tagInput){
    var id = t.getId(tagInput);
    if (isValid(id)) t.update('add', id);
  }

  function isValid(id){
    return Boolean(id) &&
      !TAGS.current.includes(id);
  }
  
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

  
  return t;
  
}));

 /*
   Entity.tags = x
 */
 
