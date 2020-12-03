export default function tags(){
  const $ = window.$;

  // IMPORTANT: views MUST supply divs with the below ids for this module to function
  var DIVS = {
    container: '#tags-container',
    control: '#tags-controls',
    edit: '#tags-edit-button'
  };
  
  var t = {}; // object for public exports
  var STATE = {}; // store

  // STORE FUNCTIONS

  // type TagsRepository = { [all: string]: TagsById, [current: string]: Array<string>, divs: Divs}
  // type TagsById = { [id: string]: Tag }
  // type DivsById = { [id: string]: string }
  // type Tag = type { name: string, description: string, id: number }
  
  /**
   * Initalization of widget 
   * @param {TagsRepository} tags
   * @param {DivsById} divs
   * @param {Boolean|Undefined} alwaysEdit
   * @return {Object}
   */
  t.init = function(tags, endpoint, alwaysEdit){
    STATE = {
      tags: tags,
      cache: {
        html: $(DIVS.container).html(),
        tags: tags.current.map(String)
      },
      endpoint: endpoint,
      alwaysEdit: Boolean(alwaysEdit)
    };

    // render immediately in perpetual edit mode, otherwise wait for click
    STATE.alwaysEdit ? renderAndHideEdit() : handleEditClick();
    
    return STATE;
  };

  // STATE SELECTORS
  
  t.get = function() {
    return STATE;
  };
  
  t.getId = function(name){
    return Object.keys(STATE.tags.byId).filter(function(k){
      return STATE.tags.byId[k].name === name;
    })[0];
  };

  t.available = function(){
    return Object.keys(STATE.tags.byId).filter(function(id){
      return isEditable(id) && !STATE.tags.current.includes(id);
    });
  };

  function isEditable(id){
    return STATE.tags.byId[id].permissions.editable;
  }

  // STATE MUTATORS
  
  t.update = function(action, id){
    t[action](id);
    t.render();
  };

  t.add = function(id) {
    STATE.tags.current = STATE.tags.current.concat(String(id));
  };
  
  t.remove = function(idToRemove){
    STATE.tags.current = STATE.tags.current.filter(function(id){
      return id !== String(idToRemove);
    });
  };

  // RENDER FUNCTIONS


  function handleEditClick(){
    $(DIVS.edit).click(renderAndHideEdit);
  }

  function renderAndHideEdit() {
    $(DIVS.edit).hide();
    renderControls();
    t.render();
  }

  function renderControls(){
    $(DIVS.control)
      .append(saveButton())
      .append(cancelButton());
  }

  function saveButton(){
    return $('<button>', {
      id: 'tags-save-button',
      text: 'save',
      click: function(e){
	e.preventDefault();
        $.post(STATE.endpoint, {tags: { ids: STATE.tags.current  }})
          .done(function(){ window.location.reload(true); });
      }
    });
  }

  function cancelButton(){
    return $('<button>', {
      id: 'tags-cancel-button',
      text: 'cancel',
      click: function(e){
	e.preventDefault();
	STATE.tags.current = STATE.cache.tags; // restore state
        STATE.alwaysEdit
	  ? t.render()    // in perpetual edit mode we only need to re-render
	  : restoreDom(); // normbyIdy, we must restore the pre-edit-mode view
      }
    });    
  }

  function restoreDom(){
    $(DIVS.container).html(STATE.cache.html);
    $('#tags-save-button').remove();
    $('#tags-cancel-button').remove();
    $(DIVS.edit).show();
  }

  t.render = function(){
    $(DIVS.container)
      .empty()
      .append(tagList())
      .append(select());
    
    $('#tags-select').selectpicker(); // possible to move this into select()?
  };
 
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
        text: STATE.tags.byId[tagId].name
      });
    });
  };
  
  function updateIfValid(tagInput){
    var id = t.getId(tagInput);
    if (isValid(id)) t.update('add', id);
  }

  function isValid(id){
    return Boolean(id) &&
      !STATE.tags.current.includes(id);
  }
  
  function tagList(){
    return $('<ul>', {id: 'tags-edit-list'})
      .append(STATE.tags.current.map(tagButton));
  }
  
  function tagButton(id){
    return isEditable(id) ? editableTagButton(id) : disabledTagButton(id);
  }

  function editableTagButton(id){
    return $('<li>', {
      class: 'tag',
      text: STATE.tags.byId[id].name
    }).append(removeIcon(id));
  }

  function removeIcon(id) {
    return $('<span>', {
      class: 'tag-remove-icon',
      click: function(){
	t.update('remove', id);
      }
    });
  }

  function disabledTagButton(id){
    return $('<li>', {
      class: 'tag-disabled',
      text: STATE.tags.byId[id].name
    }).append(lockIcon());
  }

  function lockIcon(id) {
    return $('<span>', { class: 'tag-lock-icon' });
  }

  return t;
}
