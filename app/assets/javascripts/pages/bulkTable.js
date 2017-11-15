(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'), require('../common/utility'));
  } else {
    root.bulkTable = factory(root.jQuery, root.utility);
  }
}(this, function ($, util) {

  var self = {}; // returned at bottom of file

  // STATE MANAGEMENT
  var state = {};

  // TODO: parameterize these!
  var columns = [{
    label: 'Name',
    attr:  'name',
    input: 'text'
  },{
    label: 'Entity Type',
    attr:  'primary_ext',
    input: 'select'
  },{
    label: 'Description',
    attr:  'blurb',
    input: 'text'
  }];

  var ids = {
    uploadButton:  "bulk-add-upload-button",
    notifications: "bulk-add-notifications"
  };

  self.init = function(args){
    state = Object.assign(state, {
      // id of the dom node to which this module will be appended on render
      domId: args.domId, // String
      // id of base resource with which we wish to associate many entities:
      resourceId: args.resourceId, // String
      resourceType: args.resourceType, // String (must be plural to match rails path conventions)
      // store entities, errors, and matches in hash map repositories
      // repository types given in Flow notation (see: https://flow.org/en/docs/types/objects)
      // type Entity = { [EntityAttr]: String }
      // type EntityAttr = 'id' | 'name' | 'primary_ext' | 'blurb'
      entities: args.entities || { // expose to `#init` for unit testing seam
        byId:    {},  // { [String]: Entity }
        order:   []  // [String] (order corresponds to row order of entities stored in `.byId`)
      },
      matchesByEntityId: {}, // { [String]: { byId: { [String]: EntityMatch }, order: [String] }]
      errorsByEntityId: {}, // { [String]: { [EntityAttr]: [String] } }
      canUpload: true,
      notification: ""
    });
    state.render().detectUploadSupport();

    // TODO: (ag|14-Nov-2017)
    // if we want to instantiate tables, we could:
    // * wrap all references to `state`  (including method defintions) inside the call to `#init`
    // * return `state`` here, but return `self` (or some differently named wrapper obj) from module
    // * we could then eliminate call to `Object.assign` on line 35 
    //   (which is only needed to share binding with `state` methods below)
    return self;
  };

  // PUBLIC METHODS

  // String -> Object
  self.get = function(attr){
    return util.get(state, attr);
  };

  // [String] -> Object
  self.getIn = function(path){
    return util.getIn(state, path);
  };

  // we expose below functions for testing  seams...

  // ...we cannot mutate caller.files for security reasons
  self.hasFile = function(caller){
    return Boolean(caller.files[0]);
  };

  // ...ditto
  self.getFile = function(caller){
    return caller.files[0];
  };

  // ...so we can test scenarios after csv has uploaded
  //    (without mocking file-reader behavior encapsulated above)
  self.ingestEntities = ingestEntities;

  // GETTERS

  state.getIn = self.getIn;

  // Entity -> { [id: EntityAttr]: [String]}
  state.getErrors = function(entity){
    return state.getIn(['errorsByEntityId', entity.id]) || {};
  };

  // (Entity, EntityAttr) -> [String]
  state.getErrorsByAttr = function(entity, attr){
    return state.getIn(['errorsByEntityId', entity.id, attr]);
  };

  state.getEntity = function(id){
    return state.getIn(['entities', 'byId', id]);
  };

  state.getEntityIds = function(){
    return Object.keys(state.getIn(['entities', 'byId']) || {});
  };

  state.getEntityOrder = function(){
    return state.getIn(['entities', 'order']);
  };

  state.getOrderedEntities = function(){
    return state.getIn(['entities', 'order']).map(state.getEntity);
  };

  state.getNewEntities = function(){
    return Object
      .values(state.getIn(['entities', 'byId']))
      .filter(function(entity){ return entity.id.includes("new"); });
  };

  state.getMatch = function(entity, matchId){
    return util.get(state.getMatches(entity), matchId);
  };

  state.getSelectedMatch = function(entity){
    var matchId = state.getIn(['matchesByEntityId', entity.id, 'selected']);
    return state.getMatch(entity, matchId);
  };

  state.getMatches = function(entity){
    return state.getIn(['matchesByEntityId', entity.id, 'byId']) || {};
  };

  state.getOrderedMatches = function(entity){
    return state.getIn(['matchesByEntityId', entity.id, 'order'])
      .map(function(matchId){ return state.getMatch(entity, matchId); });
  };

  // () -> String
  state.getResourcePath = function(){
    return '/' + state.resourceType + '/' + state.resourceId;
  };

  // PREDICATES

  // () -> Boolean
  state.hasNotification = function(){
    return state.notification !== "";
  };

  // () -> Boolean
  state.hasRows = function(){
    return !util.isEmpty(state.entities.order);
  };

  // Entity -> Boolean
  state.hasMatches = function(entity){
    return !util.isEmpty(state.getMatches(entity));
  };

  // () -> Boolean
  state.canSubmit = function(){
    return state.isValid() && state.isResolved();
  };

  // () -> Boolean
  state.isValid = function(){
    return Object.values(state.entities.byId)
      .every(function(entity){
        return util.isEmpty(state.getErrors(entity));
      });
  };

  // () -> Boolean
  state.isResolved = function(){
    return Object.values(state.entities.byId)
      .every(function(entity){
        return util.isEmpty(state.getMatches(entity));
      });
  };

  // SETTERS

  // String, Object -> State
  state.set = function(key, value){
    state = util.set(state, key, value);
    return state;
  };

  // [String], Object -> State
  state.setIn = function(path, value){
    state = util.setIn(state, path, value);
    return state;
  };

  // [String] -> State
  state.deleteIn = function(path){
    state = util.deleteIn(state, path);
    return state;
  };

  // Entity -> Entity
  state.addEntity = function(entity){
    state
      .setIn(['entities', 'byId', entity.id], entity)
      .setIn(['entities', 'order'], state.getIn(['entities', 'order']).concat(entity.id)
    );
    return entity;
  };

  // Entity, String, String -> State
  state.setEntityAttr = function(entity, attr, value){
    return state.setIn(['entities', 'byId', entity.id, attr], value);
  };

  // Entity -> Entity
  state.assignId = function(entity, idx){
    return Object.assign(entity, { id: "newEntity" + idx });
  };

  // Entity -> State
  state.addMatches = function(entity, matches){
    return state.setIn(
      ['matchesByEntityId', entity.id],
      {
        byId:     util.normalize(matches),
        order:    matches.map(function(match){ return match.id; }),
        selected: null
      }
    );
  };

  // Entity -> State
  state.removeMatches = function(entity){
    return state.deleteIn(['matchesByEntityId', entity.id]);
  };

  // Entity, String -> State
  state.setMatchSelection = function(entity, matchId){
    return state.setIn(['matchesByEntityId', entity.id, 'selected'], matchId);
  };

  // Entity -> State
  state.replaceWithMatch = function(entity){
    var match = state.getSelectedMatch(entity);
    return state.replaceEntity(entity, match);
  };

  // [Entities] -> State
  state.replaceWithCreatedEntities = function(createdEntities){
    return state
      .getNewEntities()
      .reduce(
        function(acc, newEntity, idx){
          return state.replaceEntity(newEntity, createdEntities[idx]);
        },
        state
      );
  };

  // Entity, Entity -> State
  state.replaceEntity = function(oldEntity, newEntity){
    return state
      .setIn(['entities', 'byId', newEntity.id], newEntity) // store newEntity as entity
      .setIn(['entities', 'order'], replaceInOrdering(oldEntity, newEntity)) // order newEntity as oldEntity was ordered
      .deleteIn(['entities', 'byId', oldEntity.id]) // remove oldEntity from store
      .deleteIn(['matchesByEntityId', oldEntity.id]); // remove oldEntity matches
  };

  // Entity, Entity -> [String]
  function replaceInOrdering(oldEntity, newEntity){
    // replace id of old entity with id of matched entity
    return state.getIn(['entities', 'order']).map(function(id){
      return id === oldEntity.id ? newEntity.id : id;
    });
  }

  // () -> State
  state.detectUploadSupport = function(){
    return util.browserCanOpenFiles() ?
      state :
      state
      .disableUpload()
      .setNotification('Your browser does not support uploading files to this page.')
      .render();
  };

  // () -> State
  state.disableUpload = function(){
    return state.set('canUpload', false);
  };

  // String -> State
  state.setNotification = function(msg){
    return state.set('notification', msg);
  };

  // () -> State
  state.clearNotification = function(){
    return state.set('notification', "");
  };

  // () -> State
  state.setSuccessNotification = function(){
    return state.setNotification(
      state.getEntityIds().length + " entities added to list"
    );
  };

  // API CALLS

  // Entity -> Promise[State]
  state.matchEntity = function(entity){
    return api
      .searchEntity(entity.name)
      .then(function(matches){ return state.addMatches(entity, matches); });
  };

  // [Entity] -> Promise[Void]
  state.matchEntities = function(entities){
    return Promise.all(entities.map(state.matchEntity));
  };

  // Entity, EntityAttr -> Promise[State]
  state.maybeMatchEntity = function(entity, attr){
    return attr === 'name' ?
      state.matchEntity(entity) :
      Promise.resolve(state);
  };

  // () -> Promise[State]
  state.createEntities = function(){
    return api
      .createEntities(state.getNewEntities())
      .then(state.replaceWithCreatedEntities);
  };

  // () -> Promise[State]
  state.createAssociations = function(){
    return api
      .addEntitiesToList(state.resourceId, state.getEntityIds())
      .then(function(){ return state; });
  };

  // () -> Promise[Void]
  state.redirectIfNoErrors = function(){
    if (!state.hasNotification()) {
      Response.redirect(state.getResourcePath(), 200);
    };
  };


  // VALIDATION

  // () -> State
  state.validate = function(){
    return state.set(
      'errorsByEntityId',
      validateEntities(Object.values(state.entities.byId), {})
    );
  };
  self.validate = state.validate; // for testing

  // type EntitiesErrors = { [id: String]: EntityError }
  // type EntityErrors = { [id: EntityAtrr]: EntityAttrErrors }
  // type EntityAttrErrors = [String]

  // [Entities], EntitiesErrors -> EntitiesErrors
  function validateEntities(entities, entitiesErrors){
    return entities.reduce(
      function(acc, entity){
        return util.set(
          acc,
          entity.id,
          validateEntity(entity, util.get(acc, entity.id))
        );
      },
      entitiesErrors || {}
    );
  };

  // expose for unit testing seam
  self.validateEntity = validateEntity;
  // Enity, EntityErrors -> EntityErrors
  function validateEntity(entity, entityErrors){
    var attrs = columns.map(function(c){ return c.attr; });
    return attrs.reduce(
      function(entityErrorsAcc, attr){
        var errors = validateAttr(entity, attr, util.get(entityErrorsAcc, attr));
        return util.isEmpty(errors) ?
          entityErrorsAcc : // don't store an entry in errors accumulator for an empty errors array
          util.set(entityErrorsAcc, attr, errors);
      },
      entityErrors || {}
    );
  };

  // Entity, EntityAttr, EntityAttrErrors -> EntityAttrErrors
  function validateAttr(entity, attr, attrErrors){
    return (util.get(validationsFor(entity), attr) || []).reduce(
      function(attrErrorsAcc, validation){
        return validation.isValid(util.get(entity, attr)) ?
          attrErrorsAcc :
          attrErrorsAcc.concat(validation.message);
      },
      attrErrors || []
    );
  }

  function validationsFor(entity){
    return entity.primary_ext === "Person" ?
      mergeValidations(commonValidations, personValidations) :
      commonValidations;
  };

  var commonValidations = {
    name: [
      {
        message: 'is required',
        isValid: function(attr){ return Boolean(attr); }
      },
      {
        message: 'must be at least 2 characters long',
        isValid: function(attr){ return attr && attr.length > 1; }
      }
    ],
    primary_ext: [
      {
        message: 'is required',
        isValid: function(attr){ return Boolean(attr); }
      },
      {
        message: 'must be either "Person" or "Org"',
        isValid: function(attr){
          return ['Person', 'Org'].some(function(validStr){ return attr === validStr; });
        }
      }
    ]
  };

  var personValidations = {
    name: [
      {
        message: 'must have a first and last name',
        isValid: function(attr){ return util.validFirstAndLastName(attr); }
      }
    ],
    primary_ext: []
  };

  function mergeValidations(v1, v2){
    return Object.keys(v1).reduce(
      function(acc, attr){
        return util.set(acc, attr, util.get(v1, attr).concat(util.get(v2, attr)));
      },
      v1
    );
  };

  // CSV UPLOAD HANLDING

  // (ReaderResult -> Void), JQueryElement -> Void
  function handleUploadThen(processFile, caller){
    if (self.hasFile(caller)) {
      var reader = new FileReader();
      reader.onloadend = function() {  // triggered when file is finished being read
        reader.result ? processFile(reader.result): console.error('Error reading csv');
      };
      reader.readAsText(self.getFile(caller)); // start reading (will trigger `onloadend` when done)
    }
  };

  // String -> Promise[Void]
  function ingestEntities (csv){
    const maybeEntities = parseEntities(csv);
    if (maybeEntities.error){
      state.setNotification(maybeEntities.error);
      return Promise.resolve(state.render());
    } else {
      return state
        .clearNotification()
        .disableUpload()
        .matchEntities(maybeEntities.result)
        .then(state.validateAndRender);
    }
  };

  // String -> [Entity]
  function parseEntities(csv) {
    return store(validateHeaders(parse(csv)));
  }

  // type MaybeEntities = { result: PapaObject | [Entity], error: ?String }

  // String -> MaybeEntities
  function parse(csv){
    var result = Papa.parse(csv, { header: true, delimiter: ",", skipEmptyLines: true });
    return util.isEmpty(result.errors) ?
      { result: result, error:  null } :
      { result: null,   error:  parseErrorMsg(result.errors[0], result.data) };
  }

  // Error, [Object] -> String
  function parseErrorMsg(error, rows){
    return "CSV format error: " + error.message +
      (util.exists(error.row) && " in row: '" + Object.values(rows[error.row]).join(",")) + "'";
  }

  // MaybeEntities -> MaybeEntities
  function validateHeaders(maybeEntities){
    if (maybeEntities.error) return maybeEntities;
    else {
      var validHeaders = columns.map(function(col){ return col.attr; }).join(",");
      var actualHeaders = maybeEntities.result.meta.fields.join(",");
      return actualHeaders === validHeaders ?
        maybeEntities :
        {
          result: null,
          error:  invalidHeadersMsg(validHeaders, actualHeaders)
        };
    }
  }

  // String, String -> String
  function invalidHeadersMsg(validHeaders, actualHeaders){
    return "Invalid headers.\n" +
      "Required: '" + validHeaders + "'\n" +
      "Provided: '" + actualHeaders + "'";
  }

  // MaybeEntities -> MaybeEntities
  function store(maybeEntities){
    if (maybeEntities.error) return maybeEntities;
    else {
      return {
        result: maybeEntities.result.data.map(state.assignId).map(state.addEntity),
        errors: null
      };
    }
  }


  // RENDERING

  state.validateAndRender = function(){
    return state.validate().render();
  };

  state.render = function(){
    $('#' + state.domId).empty();
    $('#' + state.domId)
      .append(notificationBar())
      .append(state.canUpload ? uploadContainer() : null)
      .append(state.hasRows()? tableForm() : null);
    return state;
  };

  function notificationBar(){
    return state.hasNotification() &&
      $('<div>', { id: ids.notifications })
        .append($('<div>', { class: 'alert-icon' }))
        .append($('<span>', { text: state.notification }));
  };

  function uploadContainer(){
    return $('<div>', {id: 'bulk-add-upload-container'})
      .append(uploadButton());
  }

  function uploadButton(){
    return $('<label>', {
      class: 'btn btn-primary btn-file',
      text: 'Upload CSV'
    }).append(
      $('<input>', {
        id:    ids.uploadButton,
        type:  "file",
        style: "display:none",
        change: function() { handleUploadThen(ingestEntities, this); }
      })
    );
  }

  function tableForm(){
    return $('<div>', {id: 'bulk-add-table-form' })
      .append(table())
      .append(submitButton());
  }

  function table(){
    return $('<table>', { id: 'bulk-add-table'})
      .append(thead())
      .append(tbody());
  }

  function thead(){
    return $('<thead>').append(
      $('<tr>').append(
        columns.map(function(c) {
          return $('<th>', {
            text: c.label
          });
        })
      )
    );
  }

  function tbody(){
    return $('<tbody>').append(
      state.getOrderedEntities().map(function(entity){
        return $('<tr>').append(
          columns.map(function(col, idx){
            return td(entity, col, idx);
          })
        );
      })
    );
  }

  function td(entity, col, idx){
    var errors = state.getErrorsByAttr(entity, col.attr);
    return $('<td>', {
      class: errors && "errors"
    }).append(
      $('<div>', {
        text:  util.get(entity, col.attr),
        class: 'cell-contents',
        click: function(){ makeEditable(this, entity, col); }
      })
    ).append(
      maybeMatchResolver(entity, col, idx)
    ).append(
      maybeErrorAlert(entity, col, errors)
    );
  }

  function makeEditable(contentsDiv, entity, col){
    $(contentsDiv).replaceWith($('<input>', {
      class: 'edit-cell',
      type:  'text',
      value:  util.get(entity, col.attr),
      keyup: function(e){ e.keyCode == 13 && handleCellEdit(entity, col.attr, $(this).val()); }
    }));
  };

  // Entity, String, String -> Promise[State]
  function handleCellEdit(entity, attr, value){
    state
      .setIn(['entities', 'byId', entity.id, attr], value)
      .deleteIn(['entities', 'errors', entity.id, attr])
      .maybeMatchEntity(util.set(entity, attr, value), attr) // search for the *updated* entity
      .then(s => s.validateAndRender());
  };

  function maybeErrorAlert(entity, col, errors){
    return errors && $('<div>', {
      class:         'error-alert',
      'data-toggle': 'tooltip',
      click:          function(){ makeEditable(this, entity, col);}
    })
      .append($('<div>', { class: 'alert-icon' }))
      .tooltip({
        placement: 'bottom',
        html: true,
        title: errorList(errors, col.label)
      });
  };

  function errorList(errors, label){
    return errors.map(function(err){
      return $('<div>', {
        text: '[ ! ] ' + label + ' ' + err
      });
    });
  }

  function maybeMatchResolver(entity, col, idx) {
    return idx == 0 && state.hasMatches(entity) && matchResolver(entity);
  }

  function matchResolver(entity) {
    return $('<div>', {
      class:         'resolver-anchor',
      'data-toggle': 'popover',
      click:         activatePicker
    })
      .append($('<div>', { class: 'alert-icon' }))
      .popover({
        html:     true,
        title:    'Similar entities already exist!',
        content:  matchResolverPopup(entity)
      });
  }

  function activatePicker(){
    // wait until popover is in DOM, then call `#selectpicker()` to show selectpicker
    // do i LIKE this API? HELL NO! i didn't make the JQuery madness. i just live in it.
    // -- @aguestuser (25-Oct-2017)
    setTimeout(
      function(){$(".resolver-selectpicker").selectpicker();},
      1 // only wait 1 milli
    );
  }

  function matchResolverPopup(entity) {
    return $('<div>', { class: 'resolver-popover' })
      .append(pickerContainer(entity))
      .append(createButton(entity));
  };

  function createButton(entity){
    return $('<div>', {
      class: "btn btn-danger resolver-create-btn",
      text:  "Create New Entity",
      click: function(){ handleCreateChoice(entity); }
    });
  }

  function pickerContainer(entity){
    return $('<div>', { class: 'resolver-picker-container' })
      .append(picker(entity))
      .append(pickerResultContainer())
      .append(pickerButton(entity));
  }

  function picker(entity){
    return $('<select>', {
      class:              'selectpicker resolver-selectpicker',
      title:              'Pick an existing entity...',
      'data-live-search': true,
      on:                 {
        'changed.bs.select': function(){
          handlePickerSelection(entity, $(this).val());
        }
      }
    }).append(
      state.getOrderedMatches(entity).map(function(match){
        return $('<option>', {
          class: 'resolver-option',
          text:  match.name,
          value: match.id
        });
      })
    );
  }

  function pickerResultContainer(){
    return $('<div>', { class: 'resolver-picker-result-container'});
  }

  function pickerResult(entity){
    return $('<div>', {
      class: 'resolver-picker-result'
    })
      .append($('<a>', {
        class:  'goto-link-icon',
        href:   entity.url,
        target: '_blank'
      }))
      .append($('<span>', {
        text: entity.blurb
      }));
  }

  function pickerButton(entity){
    return $('<div>', {
      class: 'btn btn-primary resolver-picker-btn',
      text:  'Use Existing Entity',
      click: function(){ handleUseExistingChoice(entity); }
    });
  };

  function submitButton(){
    return $('<button>', {
      id:       "bulk-submit-button",
      text:     "Submit",
      click:    handleSubmit
    }).prop('disabled', !state.canSubmit());
  }

  // EVENT HANDLERS

  // Entity -> Void
  function handleCreateChoice(entity){
    state
      .removeMatches(entity)
      .render();
  }

  // Entity -> Void
  function handleUseExistingChoice(entity){
    state
      .replaceWithMatch(entity)
      .render();
  }
 
 // Entity, String -> Void
  function handlePickerSelection(entity, matchId){
    state.setMatchSelection(entity, matchId);
    $(".resolver-picker-result-container")
      .empty()
      .append(pickerResult(state.getMatch(entity, matchId)));
  }

  // () -> Promise[Void]
  function handleSubmit(){
    return state
      .createEntities()
      .then(state.createAssociations)
      .catch(state.setNotification)
      .then(state.render)
      .then(state.redirectIfNoErrors);
  }

  // RETURN
  return self;
}));
