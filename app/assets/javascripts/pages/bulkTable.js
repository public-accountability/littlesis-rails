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
      // derrived
      rootId:         args.rootId,
      endpoint:       args.endpoint || "/",
      entities:       args.entities ||
                      { byId:    {},
                        order:   [],
                        matches: {},
                        errors:  {} },
      // deterministic
      canUpload:      true,
      notification:   ""
      // When/if we wish to paramaterize row fields, we would here paramaterize:
      //   1. resource type (currently always entity)
      //   2. columns by resource type (currently stored as constant above)
    });
    self.render();
    detectUploadSupport();
    return self;
  };

  // public getters

  self.get = function(attr){
    return util.get(state, attr);
  };

  self.getIn = function(attrs){
    return util.getIn(state, attrs);
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
  // without mocking file-reader behavior encapsulated above
  self.ingestEntities = ingestEntities;


  // private getters

  state.hasNotification = function(){
    return state.notification !== "";
  };

  state.hasRows = function(){
    return !util.isEmpty(state.entities.order);
  };

  state.getEntity = function(id){
    return util.getIn(state, ['entities', 'byId', id]);
  };

  state.getEntityOrder = function(){
    return util.getIn(state, ['entities', 'order']);
  };

  state.getOrderedEntities = function(){
    return util.getIn(state, ['entities', 'order']).map(state.getEntity);
  };

  state.getMatch = function(entity, matchId){
    return util.get(state.getMatches(entity), matchId);
  };

  state.getSelectedMatch = function(entity){
    var matchId = util.getIn(state, ['entities', 'matches', entity.id, 'selected']);
    return state.getMatch(entity, matchId);
  };

  state.getMatches = function(entity){
    return util.getIn(state, ['entities', 'matches', entity.id, 'byId']) || {};
  };

  state.getOrderedMatches = function(entity){
    return util.getIn(state, ['entities', 'matches', entity.id, 'order'])
      .map(function(matchId){ return state.getMatch(entity, matchId); });
  };

  state.hasMatches = function(entity){
    return !util.isEmpty(state.getMatches(entity));
  };

  // setters

  // Entity -> Entity
  state.addEntity = function(entity){
    state = util.setIn(
      util.setIn(state, ['entities', 'byId', entity.id], entity),
      ['entities', 'order'],
      util.getIn(state, ['entities', 'order']).concat(entity.id)
    );
    return entity;
  };

  // Entity -> Entity
  state.assignId = function(entity, idx){
    return Object.assign(entity, { id: "newEntity" + idx });
  };

  // [Entity] -> Promise[Void]
  state.matchEntities = function(entities){
    return Promise.all(entities.map(state.matchEntity));
  };

  // Entity -> Promise[Void]
  state.matchEntity = function(entity){
    return api.searchEntity(entity.name)
      .then(function(matches){ state.addMatches(entity, matches); });
  };

  // Entity -> Void
  state.addMatches = function(entity, matches){
    state = util.setIn(
      state,
      ['entities', 'matches', entity.id],
      {
        byId:     util.normalize(matches),
        order:    matches.map(function(match){ return match.id; }),
        selected: null
      }
    );
  };

  // Entity -> Void
  state.removeMatches = function(entity){
    state = util.deleteIn(state, ['entities', 'matches', entity.id]);
  };

  // Entity, Integer -> Void
  state.setMatchSelection = function(entity, matchId){
    state = util.setIn(state,
                       ['entities', 'matches', entity.id, 'selected'],
                       matchId);
  };

  // Entity -> Void
  state.replaceWithMatch = function(entity){
    // TODO: (ag| 29-Oct-2017) extract helpers and use function composition here?
    var match = state.getSelectedMatch(entity);
    // add match to entity store
    var state1 = util.setIn(state, ['entities', 'byId', match.id], match);
    // replace entity's id with match id in ordering list
    var state2 = util.setIn(
      state1,
      ['entities', 'order'],
      util.getIn(state, ['entities', 'order']).map(function(id){
        return id === entity.id ? match.id : id;
      })
    );
    // delete entity
    var state3 = util.deleteIn(state2, ['entities', 'byId', entity.id]);
    // delete entity matches, update state
    state = util.deleteIn(state3, ['entities', 'matches', entity.id]);
  };

  // () -> Void
  state.disableUpload = function(){
    state.canUpload = false;
  };

  // String -> Void
  state.setNotification = function(msg){
    state.notification = msg;
  };

  // () -> Void
  state.clearNotification = function(){
    state.notification = "";
  };

  // VALIDATION

  // () -> Void
  self.validate = function(){
    state = util.setIn(
      state,
      ['entities', 'errors'],
      validateEntities(Object.values(state.entities.byId), state.entities.errors)
    );
    return self;
  };

  // type EntitiesErrors = { [id: String]: EntityError }
  // type EntityErrors = { [id: EntityAtrr]: EntityAttrErrors }
  // type EntityAttr = 'id' | 'name' | 'primary_ext' | 'blurb'
  // type EntityAttrErrors = [String]

  // [Entities], EntityErrors -> EntityErrors
  function validateEntities(entities, entitiesErrors){
    return entities.reduce(
      function(acc, entity){
        return util.set(
          acc,
          entity.id,
          self.validateEntity(entity, util.get(acc, entity.id))
        );
      },
      entitiesErrors || {}
    );
  };

  self.validateEntity = function(entity, entityErrors){
    return Object.keys(entity).reduce(
      function(entityErrorsAcc, attr){
        return util.set(
          entityErrorsAcc,
          attr,
          validateAttr(entity, attr, util.get(entityErrorsAcc, attr))
        );
      },
      entityErrors || {}
    );
  };

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
    debugger;
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

  function detectUploadSupport(){
    if (!util.browserCanOpenFiles()) {
      state.disableUpload();
      state.setNotification('Your browser does not support uploading files to this page.');
      self.render();
    }
  }

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
      return Promise.resolve(self.render());
    } else {
      state.clearNotification();
      state.disableUpload();
      return state.matchEntities(maybeEntities.result)
        .then(self.render);
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

  self.render = function(){
    $('#' + state.rootId).empty();
    $('#' + state.rootId)
      .append(notificationBar())
      .append(state.canUpload ? uploadContainer() : null)
      .append(state.hasRows()? table() : null);
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

  function table(){
    return $('<table>', { id: 'bulk-add-table'})
      .append(thead())
      .append(tbody());
  };

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
            return $('<td>', {
              text: util.get(entity, col.attr)
            }).append(
              maybeResolver(entity, col, idx)
            );
          })
        );
      })
    );
  }

  function maybeResolver(entity, col, idx) {
    return idx == 0 && state.hasMatches(entity) && resolver(entity);
  }

  function resolver(entity) {
    return $('<div>', {
      class:         'resolver-anchor',
      cursor:        'pointer',
      'data-toggle': 'popover',
      click:         activatePicker
    })
      .append($('<div>', { class: 'alert-icon' }))
      .popover({
        html:     true,
        title:    'Similar entities already exist!',
        content:  resolverPopup(entity)
      });
  }

  function activatePicker(){
    // wait until popover is in DOM, then call `#selectpicker()` to show selectpicker
    // do i LIKE this API? HELL NO! i didn't make the JQuery madness. i just live in it.
    // -- @aguestuser (25-Oct-2017)
    setTimeout(
      function(){$(".resolver-selectpicker").selectpicker();},
      5
    );
  }

  function resolverPopup(entity) {
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

  // EVENT HANDLERS

  function handleCreateChoice(entity){
    state.removeMatches(entity);
    self.render();
  }

  function handleUseExistingChoice(entity){
    state.replaceWithMatch(entity);
    self.render();
  }

  function handlePickerSelection(entity, matchId){
    state.setMatchSelection(entity, matchId);
    $(".resolver-picker-result-container")
      .empty()
      .append(pickerResult(state.getMatch(entity, matchId)));
  }

  // RETURN
  return self;
}));
