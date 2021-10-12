import Papa from 'papaparse'
import { saveAs } from 'file-saver'
import utility from '../common/utility'
import 'bootstrap-select'

/** TYPES **********************************************

(in Flow notation: https://flow.org/en/docs/types/objects))

type EntityAttr = 'id' | 'name' | 'primary_ext' | 'blurb'
type Entity = { [EntityAttr]: String }

type MaybeEntities = { result: PapaObject | [Entity], error: ?String }
type EntityErrors = { [attr: EntityAtrr]: [String] }
type EntitiesErrors = { [id: String]: EntityError }

type Resource = Entity | Reference
type ResourceError = EntityErrors | ReferenceErrors

type ReferenceErrors = { ['name'|'url']: [String] }

type SpinnerElement = 'top' | 'bottom'

*********************************************************/
export default function ListBulkEntityAdder() {
  var self = {} // returned at bottom of file

  // STATE MANAGEMENT
  var state = {}

  // TODO: parameterize these!
  var columns = [{
    label: 'Name',
    attr: 'name',
    input: 'text'
  },{
    label: 'Entity Type',
    attr: 'primary_ext',
    input: 'text'
  },{
    label: 'Description',
    attr: 'blurb',
    input: 'text'
  }]

  var sampleCsv =
    'name,primary_ext,blurb\n'+
    'SampleOrg,Org,Description of SampleOrg\n' +
    'Sample Person,Person,Description of Sample Person'

  self.init = function(args){
    state = Object.assign(state, {
      // id of the dom node to which this module will be appended on render
      domId: args.domId, // String
      // id of base resource with which we wish to associate many entities:
      resourceId: args.resourceId, // String
      resourceType: args.resourceType, // String (must be plural to match rails path conventions)
      api: api, // { [String]: (*String) -> Promise[ApiJson] }
      entities: args.entities || { // expose to `#init` for unit testing seam
        byId: {},  // { [String]: Entity }
        order: []  // [String] (order corresponds to row order of entities stored in `.byId`)
      },
      matches: args.matches || {
        byEntityId: {}, // {[String]: {byId: {[String]: Entity}, order: [String], selected: String}]
        chosen: {} // { [id: String]: true } (set)
      },
      reference: args.reference || {
        name: '', // String
        url: ''  // String
      },
      errors: args.errors || {
        byEntityId: {}, // { [id: String]: { [EntityAttr]: [String] } }
        reference: {}  // { ['name'|'url']: [String] }
      },
      spinner: {
        top: false,
        bottom: false
      },
      canUpload: true,
      notification: "",
      newIdCount: args.entities ? Object.keys(args.entities.byId).length : -1
    })
    state.render().setUploadSupport()

    return self
  }

  // PUBLIC METHODS

  // String -> Object
  self.get = function(attr){
    return utility.get(state, attr)
  }

  // [String] -> Object
  self.getIn = function(path){
    return utility.getIn(state, path)
  }

  // we expose below functions for testing  seams...

  // ...we cannot mutate caller.files for security reasons
  self.hasFile = function(caller){
    return Boolean(caller.files[0])
  }

  // ...ditto
  self.getFile = function(caller){
    return caller.files[0]
  }

  // ...so we can test scenarios after csv has uploaded
  //    (without mocking file-reader behavior encapsulated above)
  self.ingestEntities = ingestEntities

  // GETTERS

  state.getIn = self.getIn

  state.getEntity = function(id){
    return state.getIn(['entities', 'byId', id])
  }

  state.getEntityIds = function(){
    return Object.keys(state.getIn(['entities', 'byId']) || {})
  }

  state.getEntityOrder = function(){
    return state.getIn(['entities', 'order'])
  }

  state.getOrderedEntities = function(){
    return state.getIn(['entities', 'order']).map(state.getEntity)
  }

  state.getNewEntities = function(){
    return Object
      .values(state.getIn(['entities', 'byId']))
      .filter(function(entity){ return entity.id.includes("new") })
  }

  state.getMatch = function(entity, matchId){
    return utility.get(state.getMatches(entity), matchId)
  }

  state.getSelectedMatch = function(entity){
    var matchId = state.getIn(['matches', 'byEntityId', entity.id, 'selected'])
    return state.getMatch(entity, matchId)
  }

  state.getMatches = function(entity){
    return state.getIn(['matches', 'byEntityId', entity.id, 'byId']) || {}
  }

  state.getOrderedMatches = function(entity){
    return state.getIn(['matches', 'byEntityId', entity.id, 'order'])
      .map(function(matchId){ return state.getMatch(entity, matchId) })
  }

  // Entity -> { [id: EntityAttr]: [String]}
  state.getEntityErrors = function(entity){
    return state.getIn(['errors', 'byEntityId', entity.id]) || {}
  }

  // (Entity, EntityAttr) -> [String]
  state.getEntityErrorsByAttr = function(entity, attr){
    return state.getIn(['errors', 'byEntityId', entity.id, attr])
  }

  // Reference -> { [id: ResourceAttr]: [String]}
  state.getReferenceErrors = function(){
    return state.getIn(['errors', 'reference']) || {}
  }

  // (Reference, ReferenceAttr) -> ?[String]
  state.getReferenceErrorsByAttr = function(attr){
    return state.getIn(['errors', 'reference', attr])
  }

  // Integer -> State
  state.incrementIdCountBy = function(n){
    return state.set('newIdCount', state.newIdCount + n)
  }

  // () -> String
  state.generateNewEntityId = function(){
    return "newEntity" + String(state.incrementIdCountBy(1).newIdCount)
  }

  // () -> String
  state.getResourcePath = function(){
    return '/' + state.resourceType + '/' + state.resourceId
  }

  // PREDICATES

  // () -> Boolean
  state.hasNotification = function(){
    return state.notification !== ""
  }

  // () -> Boolean
  state.hasRows = function(){
    return !utility.isEmpty(state.entities.order)
  }

  // Entity -> Boolean
  state.hasMatches = function(entity){
    return !utility.isEmpty(state.getMatches(entity))
  }

  // Entity -> Boolean
  state.isChosenMatch = function(entity){
    return state.getIn(['matches', 'chosen', entity.id]) || false
  }

  // () -> Boolean
  state.canSubmit = function(){
    return state.isValid() && state.isResolved()
  }

  // () -> Boolean
  state.isValid = function(){
    return state.entitiesValid && state.referenceValid()
  }

  // () -> Boolean
  state.entitiesValid = function(){
    return Object.values(state.entities.byId)
      .every(function(entity){
        return utility.isEmpty(state.getEntityErrors(entity))
      })
  }

  // () -> Boolean
  state.referenceValid = function(){
    return utility.isEmpty(state.getReferenceErrors())
  }

  // () -> Boolean
  state.isResolved = function(){
    return Object.values(state.entities.byId)
      .every(function(entity){
        return utility.isEmpty(state.getMatches(entity))
      })
  }

  // SpinnerElement -> Boolean
  state.hasSpinner = function(element){
    return state.getIn(['spinner', element])
  }

  // SETTERS

  // String, Object -> State
  state.set = function(key, value){
    state = utility.set(state, key, value)
    return state
  }

  // [String], Object -> State
  state.setIn = function(path, value){
    state = utility.setIn(state, path, value)
    return state
  }

  // [String] -> State
  state.deleteIn = function(path){
    state = utility.deleteIn(state, path)
    return state
  }

  // Entity -> Entity
  state.addIngestedEntity = function(entity){
    state
      .setIn(['entities', 'byId', entity.id], entity)
      .setIn(['entities', 'order'], state.getIn(['entities', 'order']).concat(entity.id)
      )
    return entity
  }

  // Entity -> Entity
  state.assignId = function(entity){
    return Object.assign(entity, { id: state.generateNewEntityId() })
  }

  // Entity, String, String -> State
  state.setEntityAttr = function(entity, attr, value){
    return state.setIn(['entities', 'byId', entity.id, attr], value)
  }

  // Entity -> State
  state.addMatches = function(entity, matches){
    return state.setIn(
      ['matches', 'byEntityId', entity.id],
      {
        byId: utility.normalize(matches),
        order: matches.map(function(match){ return match.id }),
        selected: null
      }
    )
  }

  // Entity -> State
  state.addEntity = function(entity, orderIdx){
    return state
      .setIn(['entities', 'byId', entity.id], entity) // store entity
      .spliceIntoOrder(entity.id, orderIdx) // order entity
      .setIn(['matches', 'byEntityId', entity.id], {}) // create blank matches repo for entity
      .setIn(['errors', 'byEntityId', entity.id], {}) // create blank errors repo
  }

  // String, Integer -> State
  state.spliceIntoOrder = function(id, idx){
    var order = state.getIn(['entities', 'order'])
    return state.setIn(
      ['entities', 'order'],
      order
      .slice(0, idx)
      .concat([id])
      .concat(order.slice(idx + 1, order.length))
    )
  }

  // Entity -> State
  state.deleteEntity = function(entity){
    return state
      .deleteIn(['entities', 'byId', entity.id])
      .deleteIn(['matches', 'byEntityId', entity.id])
      .deleteIn(['matches', 'chosen', entity.id])
      .deleteIn(['errors', 'byEntityId', entity.id])
      .setIn(['entities', 'order'], deleteFromOrdering(entity))
  }

  // Entity, Entity -> State
  state.replaceEntity = function(oldEntity, newEntity){
    var idx = state.getIn(['entities', 'order']).indexOf(oldEntity.id)
    return state
      .addEntity(newEntity, idx)
      .deleteEntity(oldEntity)
  }

  // Entity -> State
  state.removeMatches = function(entity){
    return state.deleteIn(['matches', 'byEntityId', entity.id])
  }

  // Entity, String -> State
  state.setMatchSelection = function(entity, matchId){
    return state.setIn(['matches', 'byEntityId', entity.id, 'selected'], matchId)
  }

  // Entity -> State
  state.replaceWithMatch = function(entity){
    var match = state.getSelectedMatch(entity)
    return state
      .replaceEntity(entity, match)
      .setIn(['matches', 'chosen', match.id], true)
  }

  // [Entities] -> State
  state.replaceWithCreatedEntities = function(createdEntities){
    return state
      .getNewEntities()
      .reduce(
        function(acc, newEntity, idx){
          return state.replaceEntity(newEntity, createdEntities[idx])
        },
        state
      )
  }

  // Entity, String -> Promise[State]
  state.maybeReidentifyEntity = function(entity, attr){
    return attr == 'name' ?
      state.reidentifyEntity(entity) :
      Promise.resolve(state)
  }

  // Entity -> State
  state.reidentifyEntity = function(entity){
    var newId = state.generateNewEntityId()
    return state
      .spliceNewEntityId(entity, newId)
      .matchEntity(state.getEntity(newId))
  }

  // Entity, String -> State
  state.spliceNewEntityId = function(entity, newId){
    var newEntity = utility.set(entity, 'id', newId)
    return state.replaceEntity(entity, newEntity)
  }

  // Entity -> [String]
  function deleteFromOrdering(entity){
    return state.getIn(['entities', 'order']).filter(function(id){
      return id !== entity.id
    })
  }

  // () -> State
  state.setUploadSupport = function(){
    return utility.browserCanOpenFiles() ?
      state :
      state
      .disableUpload()
      .setNotification('Your browser does not support uploading files to this page.')
      .render()
  }

  // () -> State
  state.disableUpload = function(){
    return state.set('canUpload', false)
  }

  // String -> State
  state.setNotification = function(msg){
    return state.set('notification', msg)
  }

  // () -> State
  state.clearNotification = function(){
    return state.set('notification', "")
  }

  // () -> State
  state.setSuccessNotification = function(){
    return state.setNotification(
      state.getEntityIds().length + " entities added to list"
    )
  }

  // (String, String) -> State
  state.setReferenceAttr = function(attr, value){
    return state.setIn(['reference', attr], value)
  }

  // SpinnerElement -> State
  state.setSpinner = function(element){
    return state.setIn(['spinner', element], true)
  }

  // SpinnerElement -> State
  state.unsetSpinner = function(element){
    return state.setIn(['spinner', element], false)
  }

  // API CALLS

  // Entity -> Promise[State]
  state.matchEntity = function(entity){
    return state.api
      .searchEntity(entity.name)
      .then(function(matches){ return state.addMatches(entity, matches) })
  }

  // [Entity] -> Promise[Void]
  state.matchEntities = function(entities){
    // TODO: (@aguestuser|28-Nov-2017)
    // * with large number of entities, this call will tax the server and browser
    // * consider pulling in a promise library like bluebird to support concurrency limits
    return Promise
      .all(entities.map(state.matchEntity))
      .then(function(){ return state })
  }

  // Entity, EntityAttr -> Promise[State]
  state.maybeMatchEntity = function(entity, attr){
    return attr === 'name' ?
      state.matchEntity(entity) :
      Promise.resolve(state)
  }

  // () -> Promise[State]
  state.createEntities = function(){
    var newEntities = state.getNewEntities()
    return utility.isEmpty(newEntities) ?
      Promise.resolve(state) :
      state.api
      .createEntities(newEntities)
      .then(state.replaceWithCreatedEntities)
  }

  // () -> Promise[State]
  state.createAssociations = function(){
    return state.api
      .addEntitiesToList(state.resourceId, state.getEntityIds(), state.reference)
      .then(function(){ return state })
  }

  // () -> Promise[Void]
  state.redirectIfNoErrors = function(){
    if (state.notification === '') {
      utility.redirectTo(state.getResourcePath())
    }
  }

  // RENDERING

  state.validateAndRender = function(){
    return state.validate().render()
  }

  state.render = function(){
    $('body > div.tooltip').remove() // stupid hack to fix stupid problem with tooltips
    $('#' + state.domId).empty()
    $('#' + state.domId)
      .append(notificationBar())
      .append(state.canUpload ? uploadContainer() : null)
      .append(topSpinner())
      .append(state.hasRows()? tableForm() : null)
    return state
  }

  function notificationBar(){
    return state.hasNotification() &&
      $('<div>', { id: 'notifications' })
      .append($('<div>', { class: 'alert-icon bi bi-exclamation-triangle' }))
      .append($('<span>', { text: state.notification }))
  }


  function topSpinner(){
    return state.hasSpinner('top') &&
      utility.appendSpinner($('<div>', { id: 'top-spinner' }))
  }

  function uploadContainer(){
    return $('<div>', {id: 'upload-container'})
      .append(uploadButton())
      .append(downloadButton())
  }

  function uploadButton(){
    return $('<label>', {
      class: 'btn btn-primary btn-file btn-upload',
      text: 'Upload CSV'
    }).append(
      $('<input>', {
        id: "upload-button",
        type: "file",
        change: function() { handleUploadThen(ingestEntities, this) }
      })
    )
  }

  function downloadButton(){
    return $('<button>', {
      id: 'download-button',
      class: 'btn btn-primary',
      text: 'Download Sample CSV',
      click: handleDownload
    })
  }

  function tableForm(){
    return $('<div>', {id: 'bulk-add-table-form' })
      .append(table())
      .append(referenceContainer())
      .append(submitButtonOrSpinner())
  }

  function table(){
    return $('<table>', { id: 'bulk-add-table'})
      .append(thead())
      .append(tbody())
  }

  function thead(){
    return $('<thead>').append(
      $('<tr>').append(
        columns.map(function(c) {
          return $('<th>', {
            text: c.label
          })
        })
      )
    )
  }

  function tbody(){
    return $('<tbody>').append(
      state.getOrderedEntities().map(function(entity){
        return $('<tr>').append(
          columns.map(function(col, idx){
            return td(entity, col, idx)
          })
        )
      })
    )
  }

  // Entity, AttrWrapper, Integer -> JQueryNode
  function td(entity, col, idx){
    var errors = state.getEntityErrorsByAttr(entity, col.attr)
    return errorWrapperOf(
      '<td>',
      col.attr,
      errors,
      inputWithErrorAlerts({
        className: 'cell-input',
        label: col.label,
        value: utility.get(entity, col.attr),
        errors: errors,
        handleChange: handleCellEditOf(entity, col.attr)
      })
      .attr('disabled', idx > 0 && state.isChosenMatch(entity))
    )
      .append(maybeMatchResolver(entity, col, idx))
      .append(maybeDeleteButton(entity, idx))
  }

  // String, String, [String], JQueryNode -> JQueryNode
  function errorWrapperOf(tag, className, errors, input){
    return $(tag, { class: className + (errors ? ' errors' : '') })
      .append(input)
      .append(errors && $('<div>', { class: 'alert-icon bi bi-exclamation-triangle' }))
  }

  // String, String, [String], Function -> JQueryNode
  function inputWithErrorAlerts({className, label, value, errors, handleChange}={}){
    return errorAnchorOf(
      $('<input>', {
        class: className,
        type: 'text',
        placeholder: label,
        value: value,
        change: function(){ handleChange($(this).val()) }
      }), label, errors)
  }

  // JQueryNode, String, [String] -> JQueryNode
  function errorAnchorOf(container, label, errors){
    return !errors ?
      container :
      container
      .addClass('error-alert')
      .attr('data-toggle', 'tooltip')
      .attr('onmouseout', function(){ container.find('.tooltip').hide()})
      .attr('onblur', function(){ container.find('.tooltip').hide()})
      .tooltip({
        "placement": 'bottom',
        "html": true,
        "boundary": 'window',
        "title": errorList(errors, label)
      })
  }

  // [String], String -> String
  function errorList(errors, label){
    return errors.map(function(err){
      var text = '[ ! ] ' + label + ' ' + err
      var div = utility.createElementWithText('div', text)
      return div.outerHTML
    }).join('')
  }

  // Entity, Integer -> JQueryNode
  function maybeDeleteButton(entity, idx){
    return idx === (columns.length - 1) && deleteButton(entity)
  }

  // Entity -> JQueryNode
  function deleteButton(entity){
    return $('<div>', {
      class: 'delete-icon bi bi-trash',
      title: 'delete row',
      click: function(){ handleDelete(entity) }
    })
  }

  function maybeMatchResolver(entity, col, idx) {
    return idx === 0 && state.hasMatches(entity) && matchResolver(entity)
  }



  function matchResolver(entity) {
    var anchorId = "popover" + utility.randomDigitStringId()

    return $('<div>', {
      "class": 'resolver-anchor',
      "data-toggle": 'popover',
      "click": activatePicker,
      "id": anchorId
    })
      .append($('<div>', { class: 'alert-icon bi bi-exclamation-triangle', title: 'resolve duplicates' }))
      .popover({
        html: true,
        title: 'Similar entities already exist',
        content: matchResolverPopup(entity, anchorId)
      })
  }

  function activatePicker(){
    // wait until popover is in DOM, then call `#selectpicker()` to show selectpicker
    // do i LIKE this API? HELL NO! i didn't make the JQuery madness. i just live in it.
    // -- @aguestuser (25-Oct-2017)
    setTimeout(
      function(){$(".resolver-selectpicker").selectpicker()},
      1 // only wait 1 milli
    )
  }

  function matchResolverPopup(entity, anchorId) {
    return $('<div>', { class: 'resolver-popover' })
      .append(pickerContainer(entity, anchorId))
      .append(createButton(entity, anchorId))
  }

  function createButton(entity, anchorId){
    return $('<div>', {
      class: "btn btn-danger resolver-create-btn",
      text: "Create New Entity",
      click: function(){
        hidePopover(anchorId)
        handleCreateChoice(entity)
      }
    })
  }

  function pickerContainer(entity, anchorId){
    return $('<div>', { class: 'resolver-picker-container' })
      .append(picker(entity))
      .append(pickerResultContainer())
      .append(pickerButton(entity, anchorId))
  }

  function picker(entity){
    return $('<select>', {
      class: 'selectpicker resolver-selectpicker',
      title: 'Pick an existing entity...',
      'data-live-search': true,
      on: {
        'changed.bs.select': function(){
          handlePickerSelection(entity, $(this).val())
        }
      }
    }).append(
      state.getOrderedMatches(entity).map(function(match){
        return $('<option>', {
          class: 'resolver-option',
          text: match.name,
          value: match.id
        })
      })
    )
  }

  function hidePopover(anchorId) {
    $('#' + anchorId).popover('hide')
  }

  function pickerResultContainer(){
    return $('<div>', { class: 'resolver-picker-result-container'})
  }

  function pickerResult(entity){
    return $('<div>', {
      class: 'resolver-picker-result'
    })
      .append($('<a>', {
        class: 'goto-link-icon bi bi-box-arrow-up-right',
        href: entity.url,
        target: '_blank'
      }))
      .append($('<span>', {
        text: entity.blurb
      }))
  }

  function pickerButton(entity, anchorId){
    return $('<div>', {
      class: 'btn btn-primary resolver-picker-btn',
      text: 'Use Existing Entity',
      click: function(){
        hidePopover(anchorId)
        handleUseExistingChoice(entity)
      }
    })
  }

  function referenceContainer(){
    return $('<div>', { id: 'reference-container' })
      .append($('<div>', { class: 'label', text: 'Reference' }))
      .append(referenceInputOf('name'))
      .append(referenceInputOf('url'))
  }

  function referenceInputOf(attr){
    var errors = state.getReferenceErrorsByAttr(attr)
    return errorWrapperOf(
      '<div>',
      attr,
      errors,
      inputWithErrorAlerts({
        className: 'reference-input',
        label: utility.capitalize(attr),
        value: state.getIn(['reference', attr]),
        errors: errors,
        handleChange: handleReferenceInputOf(attr)
      })
    )
  }

  function submitButtonOrSpinner(){
    return state.hasSpinner('bottom') ?
      bottomSpinner() :
      submitButton()
  }

  function bottomSpinner(){
    return utility.appendSpinner(
      $('<div>', { id: 'bottom-spinner' })
    )
  }

  function submitButton(){
    return $('<button>', {
      id: "bulk-submit-button",
      text: "Submit",
      click: handleSubmit
    }).prop('disabled', !state.canSubmit())
  }

  // VALIDATION


  // () -> State
  state.validate = function(){
    return state
      .setIn(
        ['errors', 'byEntityId'],
        validateEntities(Object.values(state.entities.byId), {})
      )
      .setIn(
        ['errors', 'reference'],
        validateReference(state.reference, {})
      )
  }
  self.validate = state.validate // for testing

  // [Entities] -> EntitiesErrors
  function validateEntities(entities){
    return entities.reduce(function(acc, entity){
      return utility.set(
        acc,
        entity.id,
        validateResource(
          entity,
          columns.map(function(c){ return c.attr }),
          validationsFor(entity)
        )
      )
    }, {})
  }


  // Reference -> ReferenceErrors
  function validateReference(reference){
    return validateResource(
      reference,
      Object.keys(reference),
      referenceValidations
    )
  }

  function validateResource(resource, attrs, validations){
    return attrs.reduce(function(resourceErrorsAcc, attr){
      var attrErrors = validateAttr(
        resource,
        attr,
        validations,
        utility.get(resourceErrorsAcc, attr)
      )
      return utility.isEmpty(attrErrors) ?
        resourceErrorsAcc : // don't store an entry in errors accumulator for an empty errors array
        utility.set(resourceErrorsAcc, attr, attrErrors)
    }, {})
  }

  // Entity, EntityAttr, EntityAttrErrors -> [String]
  function validateAttr(resource, attr, validations, attrErrors){
    return (utility.get(validations, attr) || []).reduce(
      function(attrErrorsAcc, validation){
        return validation.isValid(utility.get(resource, attr)) ?
          attrErrorsAcc :
          attrErrorsAcc.concat(validation.message)
      },
      attrErrors || []
    )
  }

  // VALIDATION RULES

  var validations = {
    required: {
      message: 'is required',
      isValid: function(attr){ return Boolean(attr) }
    },
    lengthN: function(n){
      return {
        message: 'must be at least ' + n + ' characters long',
        isValid: function(attr){ return attr && attr.length >= n }
      }
    },
    personOrOrg: {
      message: 'must be either "Person" or "Org"',
      isValid: function(attr){
        return ['Person', 'Org'].some(function(validStr){ return attr === validStr })
      }
    },
    personName: {
      message: 'must have a first and last name with no numbers',
      isValid: function(attr){ return utility.validPersonName(attr) }
    },
    validUrl: {
      message: 'must be a valid ip address',
      isValid: function(attr){ return utility.validURL(attr) }
    }
  }

  function validationsFor(entity){
    return entity.primary_ext === "Person" ?
      mergeValidations(entityValidations, personValidations) :
      entityValidations
  }

  var referenceValidations = {
    name: [
      validations.required,
      validations.lengthN(3)
    ],
    url: [
      validations.required,
      validations.validUrl
    ]
  }

  var entityValidations = {
    name: [
      validations.required,
      validations.lengthN(2)
    ],
    primary_ext: [
      validations.required,
      validations.personOrOrg
    ]
  }

  var personValidations = {
    name: [ validations.personName ],
    primary_ext: []
  }

  function mergeValidations(v1, v2){
    return Object.keys(v1).reduce(
      function(acc, attr){
        return utility.set(acc, attr, utility.get(v1, attr).concat(utility.get(v2, attr)))
      },
      v1
    )
  }

  // EVENT HANDLERS

  // CSV UPLOAD HANLDING

  // (ReaderResult -> Void), JQueryElement -> Void
  function handleUploadThen(processFile, caller){
    if (self.hasFile(caller)) {
      var reader = new FileReader()
      reader.onloadend = function() {  // triggered when file is finished being read
        reader.result ? processFile(reader.result): console.error('Error reading csv')
      }
      reader.readAsText(self.getFile(caller)) // start reading (will trigger `onloadend` when done)
    }
  }

  // String -> Promise[Void]
  function ingestEntities(csv){
    state.setSpinner('top').render()
    var maybeEntities = parseEntities(csv)
    if (maybeEntities.error){
      state.setNotification(maybeEntities.error)
      return Promise.resolve(state.render())
    } else {
      return state
        .disableUpload()
        .matchEntities(maybeEntities.result)
        .then(function(s){ return s.unsetSpinner('top') })
        .then(function(s){ return s.clearNotification() })
        .then(function(s){ return s.validateAndRender() })
    }
  }

  // String -> [Entity]
  function parseEntities(csv) {
    return store(validateHeaders(parse(csv)))
  }


  // String -> MaybeEntities
  function parse(csv){
    var result = Papa.parse(csv, { header: true, skipEmptyLines: true, transform: function(val){ return val.trim() } })
    return utility.isEmpty(result.errors) ?
      { result: result, error: null } :
      { result: null,   error: parseErrorMsg(result.errors[0], result.data) }
  }

  // Error, [Object] -> String
  function parseErrorMsg(error, rows){
    return "CSV format error: " + error.message +
      (utility.exists(error.row) && " in row: '" + Object.values(rows[error.row]).join(",")) + "'"
  }

  // MaybeEntities -> MaybeEntities
  function validateHeaders(maybeEntities){
    if (maybeEntities.error) return maybeEntities
    else {
      var validHeaders = columns.map(function(col){ return col.attr }).join(",")
      var actualHeaders = maybeEntities.result.meta.fields.join(",")
      return actualHeaders === validHeaders ?
        maybeEntities :
        {
          result: null,
          error: invalidHeadersMsg(validHeaders, actualHeaders)
        }
    }
  }


  const ACCEPTABLE_PERSON_VALUES = ['p', 'per', 'person']
  const ACCEPTABLE_ORG_VALUES = ['o', 'org', 'organization']

  // Anything -> String
  function cleanPrimaryExt(primary_ext) {
    if (typeof primary_ext === 'string') {
      if (ACCEPTABLE_PERSON_VALUES.includes(primary_ext.trim().toLowerCase())) {
        return 'Person'
      } else if (ACCEPTABLE_ORG_VALUES.includes(primary_ext.trim().toLowerCase())) {
        return 'Org'
      } else {
        return primary_ext.trim()
      }
    } else {
      return ''
    }
  }

  function handlePrimaryExtVariations(entity) {
    return Object.assign({}, entity, { "primary_ext": cleanPrimaryExt(entity.primary_ext) })
  }

  // String, String -> String
  function invalidHeadersMsg(validHeaders, actualHeaders){
    return "Invalid headers.\n" +
      "Required: '" + validHeaders + "'\n" +
      "Provided: '" + actualHeaders + "'"
  }

  // MaybeEntities -> MaybeEntities
  function store(maybeEntities){
    if (maybeEntities.error) return maybeEntities
    else {

      var result = maybeEntities.result.data
        .map(state.assignId)
        .map(handlePrimaryExtVariations)
        .map(state.addIngestedEntity)

      return { result: result, errors: null }
    }
  }

  // () -> Void
  function handleDownload(){
    saveAs(
      new File([sampleCsv], 'sample.csv', { type: 'text/csv; charset=utf-8' })
    )
  }

  // Entity -> Void
  function handleCreateChoice(entity){
    state
      .removeMatches(entity)
      .render()
  }

  // Entity -> Void
  function handleUseExistingChoice(entity){
    state
      .replaceWithMatch(entity)
      .render()
  }

  // Entity, String -> Void
  function handlePickerSelection(entity, matchId){
    state.setMatchSelection(entity, matchId)
    $(".resolver-picker-result-container")
      .empty()
      .append(pickerResult(state.getMatch(entity, matchId)))
  }

  // (Entity, EntityAttr) -> (String) -> Promise[State]
  function handleCellEditOf(entity, attr){
    return function(val){
      return handleCellEdit(entity, attr, val)
    }
  }

  // Entity, String, String -> Promise[State]
  function handleCellEdit(entity, attr, value){
    var newEntity = utility.set(entity, attr, value)
    return state
      .setIn(['entities', 'byId', entity.id], newEntity)
      .maybeReidentifyEntity(newEntity, attr)
      .then(state.validateAndRender)
  }

  // String -> String -> State
  function handleReferenceInputOf(attr){
    return function(value){
      return handleReferenceInput(attr, value)
    }
  }

  // String, String -> State
  function handleReferenceInput(attr, value){
    return state
      .setReferenceAttr(attr, value)
      .validateAndRender()
  }

  // () -> Promise[Void]
  function handleSubmit(){
    return state
      .setSpinner('bottom')
      .render()
      .createEntities()
      .then(state.createAssociations)
      .catch(state.setNotification)
      .then(function(){ return state.unsetSpinner('bottom') })
      .then(state.render)
      .then(state.redirectIfNoErrors)
  }

  // Entity -> State
  function handleDelete(entity){
    return state
      .deleteEntity(entity)
      .render()
  }

  // RETURN
  return self
}
