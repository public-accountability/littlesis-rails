describe('Bulk Table module', () => {

  // ASYNC TUNING
  // increase these in case of wierd non-deterministic failures due to async issues
  const asyncDelay = 10; // millis to wait for async ops like csv upload, api calls, etc..
  const delayMultiplier = 1.5; // only neeed for uploading csv setup (currently)

  // FIXTURES
  const columns = fxt.entityColumns;
  const newEntities = fxt.newEntities;
  const mixedEntities = fxt.newAndExistingEntities;
  const csvValid = fxt.entityCsvValid;
  const csvValidOnlyMatches = fxt.entityCsvValidOnlyMatches;
  const csvValidNoMatches = fxt.entityCsvValidNoMatches;
  const csvSample = fxt.entityCsvSample;
  const searchEntityFake = fxt.entitySearchFake;
  const searchResultsFor = fxt.entitySearchResultsFor;
  const reference = fxt.reference;
  const testDom ='<div id="test-dom"></div>';

  // SPIES
  let browserCanOpenFilesSpy,
      searchEntitySpy,
      createEntitiesSpy,
      addEntitiesToListSpy,
      hasFileSpy,
      getFileSpy,
      redirectSpy,
      appendSpinnerSpy,
      removeSpinnerSpy;

  // STUB VALUES
  let file, errorMsg;

  // HELPERS

  const defaultState = () => ({
    // this is a thunk b/c  we *must* initialize api spies inside of before block in jasmine :/
    domId:        "test-dom",
    resourceType: "lists",
    resourceId:   "1",
    api: {
      searchEntity:       searchEntitySpy,
      createEntities:     createEntitiesSpy,
      createAssociations: addEntitiesToListSpy
    }
  });

  // Integer -> Promise[Void]
  const wait = (millis) => new Promise((rslv,rjct) => setTimeout(rslv, millis));

  // String -> Promise[Void]
  const setupWithCsv = (csv) => {
    file = new File([csv], "test.csv", {type: "text/csv"});
    hasFileSpy.and.returnValue(true);
    getFileSpy.and.returnValue(file);

    bulkTable.init(defaultState());
    $('#upload-button').change();
    return wait(delayMultiplier * asyncDelay); // multiply delay to accomodate multiple async ops
  };

  // (String, () -> JQueryNode, String) -> Promise[Void]
  const setupEdit = (csv, findInput, value) => {
    return setupWithCsv(csv)
      .then(() => editCell(findInput(), value))
      .then(() => wait(asyncDelay));
  };

  // JQueryNode, String -> Void
  const editCell = (input, newValue) => {
    input.val(newValue).trigger('change');
  };

  // EntitiesById, ApiJson, ApiJson -> Promise[Void]
  const setupSubmit = (entitiesById, createEntitiesVal, addEntitiesToListVal) => {

    createEntitiesSpy.and.returnValue(createEntitiesVal);
    addEntitiesToListSpy.and.returnValue(addEntitiesToListVal);

    bulkTable.init(Object.assign(
      {},
      defaultState(),
      {
        entities: { byId: entitiesById, order: Object.keys(entitiesById) },
        reference: reference
      }
    ));

    $('#bulk-submit-button').trigger('click');
    return wait(asyncDelay);
  };


  // Void -> JQueryNode
  const findFirstRow = () => $("#bulk-add-table tbody tr:nth-child(1)");
  const findSecondRow = () => $("#bulk-add-table tbody tr:nth-child(2)");

  // SUITE SETUP & TEARDOWN
  
  beforeEach(() => {
    hasFileSpy = spyOn(bulkTable, 'hasFile');
    getFileSpy = spyOn(bulkTable, 'getFile');
    searchEntitySpy = searchEntitySpy = spyOn(api, 'searchEntity').and.callFake(searchEntityFake);
    createEntitiesSpy = spyOn(api, 'createEntities');
    addEntitiesToListSpy = spyOn(api, 'addEntitiesToList');
    redirectSpy = spyOn(utility, 'redirectTo').and.callFake(() => null);
    $('body').append(testDom);
  });

  afterEach(() => { $('#test-dom').remove(); });

  // SPECS (finally!)
  
  describe('initialization', () => {

    beforeEach(() => bulkTable.init(defaultState()));

    it('stores a reference to its root dom node', () => {
      expect(bulkTable.get('domId')).toEqual('test-dom');
    });

    it('stores a reference to id of the resource it is bulk modifying', () => {
      expect(bulkTable.get('resourceId')).toEqual('1');
    });

    it('stores a reference to type of the resource it is bulk modifying', () => {
      expect(bulkTable.get('resourceType')).toEqual('lists');
    });

    it('stores references to its api methods', () => {
      expect(bulkTable.get('api')).toEqual({
        searchEntity:       searchEntitySpy,
        createEntities:     createEntitiesSpy,
        createAssociations: addEntitiesToListSpy
      });
    });

    it('initializes empty entity repository', () =>{
      expect(bulkTable.get('entities')).toEqual({
        byId:  {},
        order: []
      });
    });

    it('initializes empty matches repository', () => {
      expect(bulkTable.get('matches')).toEqual({
        byEntityId: {},
        chosen:     {}
      });
    });

    it('initializes empty errors repository', () => {
      expect(bulkTable.get('errors')).toEqual({
        byEntityId: {},
        reference:  {}
      });
    });

    it('assumes it can upload by default', () => {
      expect(bulkTable.get('canUpload')).toBeTrue();
    });

    it('initializes an empty notification holder', () => {
      expect(bulkTable.get('notification')).toEqual('');
    });

    describe('detecting upload/download support', () => {

      describe("when browser can open files", () => {

        beforeEach(() => {
          browserCanOpenFilesSpy = spyOn(utility, 'browserCanOpenFiles').and.returnValue(true);
          bulkTable.init(defaultState());
        });

        it('shows an upload button', () => {
          expect($('#upload-button')).toExist();
        });

        it('shows a download button', () => {
          expect($('#download-button')).toExist();
        });
      });

      describe('when browser cannot open files', () => {

        beforeEach(() => {
          browserCanOpenFilesSpy = spyOn(utility, 'browserCanOpenFiles').and.returnValue(false);
          bulkTable.init(defaultState());
        });

        it('hides the upload button', () => {
          expect($('#upload-button')).not.toExist();
        });

        it('hides the download button', () => {
          expect($('#download-button')).not.toExist();
        });

        it('displays an error message', () => {
          expect($('#notifications').html()).toMatch('Your browser');
        });
      });
    });
  });


  describe('uploading csv', () => {

    describe("with well-formed csv", () => {

      beforeEach(done => {
        appendSpinnerSpy = spyOn(utility, 'appendSpinner');
        removeSpinnerSpy = spyOn(utility, 'removeSpinner');
        setupWithCsv(csvValid).then(done);
      });

      it('stores entity data', () => {
        expect(bulkTable.getIn(['entities', 'byId'])).toEqual({
          newEntity0: newEntities['newEntity0'],
          newEntity1: newEntities['newEntity1']
        });
      });

      it('stores row ordering', () => {
        expect(bulkTable.getIn(['entities', 'order'])).toEqual(Object.keys(newEntities));
      });

      it('hides upload button', () => {
        expect($('#upload-button')).not.toExist();
      });

      it('shows and hides a spinner', () => {
        expect(appendSpinnerSpy).toHaveBeenCalled();
        expect($("#top-spinner")).not.toExist();
      });
    });

    describe("With alternative Person/Org delcarations", () => {
      beforeEach(done => {
        setupWithCsv(fxt.entityCsvValidAltType).then(done);
      });

      it('stores entity data', () => {
        expect(bulkTable.getIn(['entities', 'byId'])).toEqual({
          newEntity0: { "name": 'TestOrg1', "primary_ext": 'Org', "blurb": 'test org 1 blurb', "id": 'newEntity0' },
	  newEntity1: { "name": 'TestOrg2', "primary_ext": 'Org', "blurb": 'test org 2 blurb', "id": 'newEntity1' },
	  newEntity2: { "name": 'Test Person One', "primary_ext": 'Person', "blurb": 'test person 1 blurb', "id": 'newEntity2' },
	  newEntity3: { "name": 'Test Person Two', "primary_ext": 'Person', "blurb": 'test person 2 blurb', "id": 'newEntity3' }
        });
      });

    });

    describe('with invalid header fields', () => {

      const csvInvalidHeaders = "foo,bar\nbaz,bam\n";
      beforeEach(done => setupWithCsv(csvInvalidHeaders).then(done));

      it('does not store csv data', () => {
        expect(bulkTable.getIn(['entities', 'byId'])).toEqual({});
      });

      it('displays an error message', () => {
        expect($("#notifications")).toContainText("Invalid headers");
      });

      it('still shows upload button', () => {
        expect($('#upload-button')).toExist();
      });
    });

    describe('with incorrectly formatted csv', () => {

      const csvInvalidShape = "name,primary_ext,blurb\nfoo,bar\n";
      beforeEach(done => setupWithCsv(csvInvalidShape).then(done));

      it('does not store csv data', () => {
        expect(bulkTable.getIn(['entities', 'byId'])).toEqual({});
      });

      it('displays an error message', () => {
        var notification = $("#notifications").text();
        expect($("#notifications")).toContainText("CSV format error");
      });

      it('still shows upload button', () => {
        expect($('#upload-button')).toExist();
      });
    });

    describe('re-submitting valid csv after an invalid upload', () => {

      beforeEach(done => {
        return setupWithCsv("foobar")
          .then(() => {
            getFileSpy.and.returnValue(new File([csvValid], "_.csv", { type: "text/csv"} ));    
            $('#upload-button').change(); 
          })
          .then(() => wait(asyncDelay))
          .then(done);
      });

      it('clears the error message', () => {
        expect($("notifications")).not.toExist();
      });

      it('hides the upload button', () => {
        expect($('#upload-button')).not.toExist();
      });
    });
  });

  describe('downloading', () => {

    let saveAsSpy;

    beforeEach(() =>  {
      saveAsSpy = spyOn(window, 'saveAs');
      bulkTable.init(defaultState());
    });

    it('saves a sample csv to the user\'s file system', () => {
      $('#download-button').click();
      expect(saveAsSpy).toHaveBeenCalledWith(
        new File([csvSample], 'sample.csv', { type: 'text/csv; charset=utf-8' })
      );
    });
  });

  describe('layout', () => {

    beforeEach(done => setupWithCsv(csvValid).then(done));
    
    describe('table', () => {

      it('exists', done => {
        wait(asyncDelay - 1).then(() => {
          expect($('#test-dom table#bulk-add-table')).toExist();
          done();
        });
      });

      it('has columns labeling entity fields', () => {
        const thTags = $('#bulk-add-table thead tr th').toArray();
        expect(thTags).toHaveLength(3);
        thTags.forEach((th, idx) => expect(th).toHaveText(columns[idx].label));
      });

      it('has rows showing values of entity fields', () => {
        const rows = $('#bulk-add-table tbody tr').toArray();
        expect(rows).toHaveLength(2);
        rows.forEach((row, i) => {
          $(row).find('input').toArray().forEach((input, j) => {
            expect(input).toHaveValue(fxt.newEntities[`newEntity${i}`][columns[j].attr]);
          });
        });
      });

      it('has a delete button for every row', () => {
        $('#bulk-add-table tbody tr')
          .toArray()
          .forEach(row => {
            expect($(row).find('.delete-icon')).toExist();
          });
      });
    });

    describe('reference container', () => {

      it('has a label', () => {
        expect($('#reference-container div.label')).toExist();
        expect($('#reference-container div.label')).toHaveText('Reference');
      });

      it('has a name input field', () => {
        expect($('#reference-container div.name input')).toExist();
        expect($('#reference-container div.name input')).toHaveAttr('placeholder', 'Name');
      });

      it('has a url input field', () => {
        expect($('#reference-container div.url input')).toExist();
        expect($('#reference-container div.url input')).toHaveAttr('placeholder', 'Url');
      });
    });

    it('has a submit button', () => {
      expect($("#bulk-submit-button")).toExist();
      expect($("#bulk-submit-button")).toHaveText("Submit");
    });
  });

  describe('entity resolution', () => {

    beforeEach(done => setupWithCsv(csvValid).then(done));

    describe('search', () => {

      it('searches littlesis for entities with same name as user submissions', () => {
        expect(searchEntitySpy).toHaveBeenCalledWith(newEntities.newEntity0.name);
        expect(searchEntitySpy).toHaveBeenCalledWith(newEntities.newEntity1.name);
      });

      it('stores list of search matches in memory', () => {
        expect(bulkTable.getIn(['matches', 'byEntityId'])).toEqual({
          newEntity0: {
            byId:     utility.normalize(searchResultsFor(newEntities.newEntity0)),
            order:    ["00", '10', '20'],
            selected: null
          },
          newEntity1: {
            byId:     {},
            order:    [],
            selected: null
          }
        });
      });
    });

    describe('alert icons', () => {
      afterEach( () => $('div.popover').remove() );

      it('displays alert icons next to rows with search matches', () => {
        expect(findFirstRow().find(".resolver-anchor")).toExist();
      });

      it('does not display alert icons next to rows with no search matches', () => {
        expect(findSecondRow().find(".resolver-anchor")).not.toExist();
      });

      it('shows a popover when user clicks on alert icon', () => {
        findFirstRow().find('.resolver-anchor').trigger('click');
        expect($(".resolver-popover")).toExist();
      });
    });

    describe('popover', () => {

      let popover;
      let popoverId;
      const matches = searchResultsFor(newEntities.newEntity0);

      beforeEach(done => {
        findFirstRow().find(".resolver-anchor").trigger('click');
        wait(asyncDelay).then(() => {
	  popoverId = '#' + findFirstRow().find(".resolver-anchor").attr('aria-describedby');
          popover = $(popoverId);
          done();
        });
      });

      afterEach( () => $('div.popover').remove() );

      it('has a title', () => {
        expect(popover.find(".popover-header")).toHaveText("Similar entities already exist");
      });

      it('has a selectpicker with all matched entities', () => {
        matches.forEach(match => {
          expect(popover.find(".resolver-selectpicker")).toContainText(match.name);
        });
      });

      it('has a button to use an existing entity', () => {
        expect(popover.find(".resolver-picker-btn")).toContainText("Use Existing");
      });

      it('has a button to create a new entity', () => {
	expect(popover.find(".resolver-create-btn")).toContainText("Create New");
      });

      describe('when user selects an entity from the picker', () => {

        beforeEach(() => popover.find('select').val(matches[0].id).trigger('change'));

        it('records the selection in memory', () => {
          expect(bulkTable.getIn(['matches', 'byEntityId', 'newEntity0', 'selected']))
            .toEqual(matches[0].id);
        });

        it('shows a section about user selection below the picker', () => {
          expect(popover.find(".resolver-picker-result-container"))
            .toContainElement(".resolver-picker-result");
        });

        it('shows the matched entity blurb below the picker', () => {
          expect(popover.find(".resolver-picker-result")).toContainText(matches[0].blurb);
        });

        it('shows a glyph-link to the matched entity\'s profile below the picker', () => {
          expect(popover.find(".resolver-picker-result")).toContainElement('a.goto-link-icon');
          expect(popover.find("a.goto-link-icon")).toHaveAttr("href", matches[0].url);
        });
      });

      describe('when user chooses `Use Existing Entity`', () => {
	

        beforeEach(() => {
          popover.find('select').val(matches[0].id).trigger('change');
          popover.find('.resolver-picker-btn').trigger('click');
        });

	afterEach( () => $('div.popover').remove() );

        it('overwrites user-submitted entity with matched entity', () => {
          expect(bulkTable.getIn(['entities', 'byId', matches[0].id])).toEqual(matches[0]);
          expect(bulkTable.getIn(['entities', 'byId', 'newEntity0'])).not.toExist();
          expect(bulkTable.getIn(['entities', 'order', 0])).toEqual(matches[0].id);
        });

        it('stores no matches for the user-submitted entity', () => {
          expect(bulkTable.getIn(['entities', 'matches', 'newEntity0'])).not.toExist();
        });

        it('stores no matches for the already-matched entity', () => {
          expect(bulkTable.getIn(['entities', 'matches', matches[0].id])).not.toExist();
        });

        it('stores the id of the chosen match', () => {
          expect(bulkTable.getIn(['matches', 'chosen', matches[0].id])).toBeTrue();
        });

        it('closes the popover', () => {
          expect(findFirstRow().find(".resolver-popover")).not.toExist();
        });

        it('removes the alert icon next to the row', () => {
          expect(findFirstRow().find(".resolver-anchor")).not.toExist();
        });

        it('disables every input but the name input in the matched row', () => {
          expect(findFirstRow().find('.name input')).not.toBeDisabled();
          expect(findFirstRow().find('.primary_ext input')).toBeDisabled();
          expect(findFirstRow().find('.blurb input')).toBeDisabled();
        });
      });

      describe('when user chooses `Create New Entity`', () => {

        beforeEach(() => {
          popover.find('.resolver-create-btn').trigger('click');
        });

        it('deletes matches for the user-submitted entity', () => {
          expect(bulkTable.getIn(['entities', 'matches', 'newEntity0'])).toEqual(undefined);
        });

        it('closes the popover', () => {
          expect(findFirstRow().find(".resolver-popover")).not.toExist();
        });

        it('removes the alert icon next to the row', () => {
          expect(findFirstRow().find(".resolver-anchor")).not.toExist();
        });
      });
    });
  });

  describe('editing', () => {

    describe('table', () => {

      describe('contents of a valid cell', () => {

        const findInput = () => findFirstRow().find('td:nth-child(3) input');
        beforeEach(done => setupEdit(csvValid, findInput, 'foobar').then(done));

        it('updates cell', () => {
          expect(findInput()).toHaveValue('foobar');
        });

        it('updates store', () => {
          expect(bulkTable.getIn(['entities', 'byId', 'newEntity0', 'blurb']))
            .toEqual('foobar');
        });
      });

      describe('contents of an invalid cell', () => {

        const csv = "name,primary_ext,blurb\nvalid name,x,y\n";
        const findInput = () => findFirstRow().find('td:nth-child(2) input');
        beforeEach(done => setupEdit(csv, findInput, 'Person').then(done));

        it('updates cell', () => {
          expect(findInput()).toHaveValue('Person');
        });

        it('updates store', () => {
          expect(bulkTable.getIn(['entities', 'byId', 'newEntity0', 'primary_ext']))
            .toEqual('Person');
        });
      });

      describe('contents of name cell', () => {

        const findInput = () => findSecondRow().find('td:nth-child(1) input');

        describe('when no match has been chosen', () => {

          beforeEach(done => setupEdit(csvValid, findInput, newEntities.newEntity0.name).then(done));

          it('searches for entities matching new name', () => {
            expect(searchEntitySpy).toHaveBeenCalledWith(newEntities.newEntity0.name);
          });

          it('stores search matches', () => {
            // id will be incremented because entities are always reidentified after name edited
            expect(bulkTable.getIn(['matches', 'byEntityId', 'newEntity2'])).toExist();
          });

          it('alerts user to duplicates', () => {
            expect(findSecondRow().find(".resolver-anchor")).toExist();
          });
        });

        describe('after a match has been chosen', () => {

          const entities = fxt.newAndExistingEntities;
          const name = newEntities.newEntity0.name;

          beforeEach(done => {
            bulkTable.init(Object.assign(
              {},
              defaultState(),
              {
                entities: {
                  byId: entities,
                  order: ['newEntity0', '101']
                },
                matches: {
                  byEntityId: {},
                  chosen: { 101: true }
                }
              }
            ));
            editCell(findInput(), newEntities.newEntity0.name);
            wait(asyncDelay).then(done);
          });

          it('replaces edited entity id with new placeholder id', () => {
            expect(bulkTable.getIn(['entities', 'byId', '101'])).not.toExist();
            expect(bulkTable.getIn(['entities', 'byId', 'newEntity3'])).toEqual(
              Object.assign({}, entities['101'], {
                id: 'newEntity3', // see above comment
                name: name
              })
            );
          });

          it('uses new id for row ordering', () => {
            expect(bulkTable.getIn(['entities', 'order']))
              .toEqual(['newEntity0', 'newEntity3']);
          });

          it('searches for entities matching new name', () => {
            expect(searchEntitySpy).toHaveBeenCalledWith(name);
          });

          it('uses new id for storing search matches', () => {
            expect(bulkTable.getIn(['matches', 'byEntityId', 'newEntity3'])).toExist();
          });

          it('removes entity from set of chosen entities', () => {
            expect(bulkTable.getIn(['matches', 'chosen'])).toEqual({});
          });

          it('restores editability to row cells', () => {
            findFirstRow().find('input').toArray().forEach(input => {
              expect($(input)).not.toBeDisabled();
            });
          });
        });
      });
    });

    describe('reference', () => {

      beforeEach(done => setupWithCsv(csvValid).then(done));

      it('updates the name', () => {
        $('#reference-container .name input').val('Wikipedia').trigger('change');
        expect(bulkTable.getIn(['reference', 'name'])).toEqual('Wikipedia');
      });

      it('updates the url', () => {
        $('#reference-container .url input').val('https://wikipedia.org').trigger('change');
        expect(bulkTable.getIn(['reference', 'url'])).toEqual('https://wikipedia.org');
      });
    });
  });

  describe('validation', () => {

    const validEntity = {
      id:          'fakeId',
      name:        'Trystero',
      primary_ext: 'Org',
      blurb:       'Starry skein of night.'
    };

    const validReference = {
      name: 'Pynchon Wiki',
      url:  'https://pynchonwiki.com'
    };

    describe('entity rules', () => {

      const stateOf = (entitySpec) => Object.assign({}, defaultState(), {
        entities: {
          byId: { fakeId: Object.assign({}, validEntity, entitySpec) },
          order: ['fakeId']
        },
        reference: validReference
      });

      const errorsFor =(entitySpec) =>
            bulkTable
            .init(stateOf(entitySpec))
            .validate()
            .getIn(['errors', 'byEntityId', 'fakeId']);

      it('handles a valid entity', () => {
        expect(errorsFor(validEntity)).toEqual({});
      });

      it('does not require a blurb', () => {
        expect(errorsFor({ blurb: '' })).toEqual({});
      });

      it('requires a name', () => {
        expect(errorsFor({ name: "" })).toEqual({
          name: ['is required', 'must be at least 2 characters long']
        });
      });

      it('requires a name be at least two characters', () => {
        expect(errorsFor({ name: "x" })).toEqual({
          name: ['must be at least 2 characters long']
        });
      });

      it('requires a primary extension', () => {
        expect(errorsFor({ primary_ext: "" })).toEqual({
          primary_ext: ['is required', 'must be either "Person" or "Org"']
        });
      });

      it('requires a primary extension be either `Person` or `Org`', () => {
        expect(errorsFor({ primary_ext: "tommyknocker" })).toEqual({
          primary_ext: ['must be either "Person" or "Org"']
        });
      });

      it('requires a person to have a first and last name', () => {
        expect(errorsFor({ primary_ext: "Person", name:"duende" })).toEqual({
          name: ['must have a first and last name with no numbers']
        });
      });

      it('requires a person to not have numerical characters', () => {
        expect(errorsFor({ primary_ext: "Person", name:"f00 b4r" })).toEqual({
          name: ['must have a first and last name with no numbers']
        });
      });

      it('handles multiple simultaneous errors', () => {
        expect(errorsFor({ primary_ext: "", name:"" })).toEqual({
          name:        ['is required', 'must be at least 2 characters long'],
          primary_ext: ['is required', 'must be either "Person" or "Org"']
        });
      });
    });

    describe('reference rules', () => {

      const stateOf = (referenceSpec) => Object.assign({}, defaultState(), {
        entities: { byId: { fakeId: validEntity }, order: [] },
        reference: Object.assign({}, validReference, referenceSpec)
      });

      const errorsFor =(referenceSpec) =>
            bulkTable
            .init(stateOf(referenceSpec))
            .validate()
            .getIn(['errors', 'reference']);

      it('requires a name', () => {
        expect(errorsFor({ name: "" })).toEqual({
          name: ['is required', 'must be at least 3 characters long']
        });
      });

      it('requires a name be at least three characters', () => {
        expect(errorsFor({ name: "x" })).toEqual({
          name: ['must be at least 3 characters long']
        });
      });

      it('requires a url', () => {
        expect(errorsFor({ url: "" })).toEqual({
          url: ['is required', 'must be a valid ip address']
        });
      });

      it('requires url to be a valid ip address', () => {
        expect(errorsFor({ url: "xxx" })).toEqual({
          url: ['must be a valid ip address']
        });
      });
    });

    describe('showing error alerts', () => {

      const csv = "name,primary_ext,blurb\nx,y,z\n";
      beforeEach(done => setupWithCsv(csv).then(done));

      const shouldShowErrors = (cell) => {
        expect(cell).toHaveClass("errors");
        expect(cell.find(".error-alert")).toExist();
        expect(cell.find(".alert-icon")).toExist();
      };

      const findFirstInput = () => findFirstRow().find('td:nth-child(1) .cell-input');

      it('highlights invalid entity name input', () => {
        shouldShowErrors(findFirstRow().find('td:nth-child(1)'));
      });

      it('highlights invalid entity primary extension input', () => {
        shouldShowErrors(findFirstRow().find('td:nth-child(2)'));
      });

      it('highlights invalid reference name input', () => {
        shouldShowErrors($("#reference-container .name"));
      });

      it('highlights invalid reference url input', () => {
        shouldShowErrors($("#reference-container .url"));
      });

      it('shows error tooltip on mouseenter', () => {
        const input = findFirstInput();
        input.trigger('mouseenter');
	expect($('#' + input.attr('aria-describedby'))).toContainText('[ ! ] Name must be');
	input.trigger('mouseout');
      });

      it('hides error tooltip on mouseout', () => {
        const input = findFirstInput();
        input.trigger('mousenter');
        input.trigger('mouseout');
        expect(input.parent().find('.tooltip')).not.toExist();
      });

      xit('shows error tooltip on focus', done => {  // ie: tabbing in
        // NOTE (@aguestuser|24-Nov-2017)
        // works in browser, test fails non-deterministically
        // due to async issues i don't care to address ATM
        const input = findFirstInput();
        input.trigger('focus');
        expect(input.parent().find('.tooltip')).toExist();
      });

      xit('hides error tooltip on blur', () => { // ie: tabbing out
        // NOTE (@aguestuser|24-Nov-2017)
        // works in browser, test fails non-deterministically
        // due to async issues i don't care to address ATM
        const input = findFirstInput();
        input.trigger('focus');
        input.trigger('blur');
        expect(input.parent().find('.tooltip')).not.toExist();
      });
    });

    describe('removing error alerts', () => {

      const csv = "name,primary_ext,blurb\nx,y,z\n";

      describe('in a name field', () => {
        const findInput = () => findFirstRow().find('td:nth-child(1) input');
        beforeEach(done => setupEdit(csv, findInput , 'Valid Name').then(done));

        it('removes alert after error is fixed', () => {
          expect(findInput().parent()).not.toHaveClass("errors");
        });
      });

      describe('in a primary_ext field', () => {
        const findInput = () => findFirstRow().find('td:nth-child(2) input');
        beforeEach(done => setupEdit(csv, findInput , 'Person').then(done));

        it('removes alert after error is fixed', () => {
          expect(findInput().parent()).not.toHaveClass("errors");
        });
      });

      describe('in a reference name field', () => {
        const findInput = () => $("#reference-container div.name input");
        beforeEach(done => setupWithCsv(csv).then(done));

        it('removes alert after error is fixed', () => {
          expect(findInput()).toHaveClass("error-alert");
          editCell(findInput(), 'Pynchon Wiki');
          expect(findInput()).not.toHaveClass("error-alert");
        });
      });

      describe('in a reference url field', () => {
        const findInput = () => $("#reference-container div.url input");
        beforeEach(done => setupWithCsv(csv).then(done));

        it('removes alert after error is fixed', () => {
          expect(findInput()).toHaveClass("error-alert");
          editCell(findInput(), 'http://pynchonwiki.com');
          expect(findInput()).not.toHaveClass("error-alert");
        });
      });
    });
  });

  describe('deleting', () => {

    beforeEach(() => {
      bulkTable.init(Object.assign(
        {},
        defaultState(),
        {
          entities: {
            byId: mixedEntities,
            order: ['newEntity0', '101']
          },
          matches: {
            byEntityId: {
              newEntity0: searchResultsFor(newEntities.newEntity0)
            },
            chosen: {
              101: true
            }
          }
        },
      ));
    });

    it('removes an entity from the entities repository', () => {
      const count = () => Object.keys(bulkTable.getIn(['entities', 'byId'])).length;

      expect(count()).toEqual(2);
      $('.delete-icon')[0].click();
      expect(count()).toEqual(1);
    });

    it('removes an entity from the matches repository', () => {
      const count = () => Object.keys(bulkTable.getIn(['matches', 'byEntityId'])).length;

      expect(count()).toEqual(1);
      $('.delete-icon')[0].click();
      expect(count()).toEqual(0);
    });

    it('removes an entity from the chosen matches repository', () => {
      const count = () => Object.keys(bulkTable.getIn(['matches', 'chosen'])).length;

      expect(count()).toEqual(1);
      $('.delete-icon')[1].click();
      expect(count()).toEqual(0);
    });

    it('removes an entity from the order list', () => {
      const count = () => bulkTable.getIn(['entities', 'order']).length;

      expect(count()).toEqual(2);
      $('.delete-icon')[0].click();
      expect(count()).toEqual(1);
    });

    it('removes a row from the table', () => {
      const count = () => $('#bulk-add-table tbody tr').length;

      expect(count()).toEqual(2);
      $('.delete-icon')[0].click();
      expect(count()).toEqual(1);
    });
  });

  describe('form submission', () => {

    const inputReference = () => {
      $("#reference-container .name input").val(reference.name).trigger('change');
      $("#reference-container .url input").val(reference.url).trigger('change');
    };

    describe('submit button status', () => {

      describe('there are invalid reference fields', () => {
        beforeEach(done => {
          setupWithCsv(csvValid)
            .then(() => wait(asyncDelay)) // because first test in block
            .then(done);
        });

        it('is disabled', () => {
          expect($("#bulk-submit-button")).toBeDisabled();
        });
      });

      describe('there are invalid table fields', () => {
        const csvInvalid = "name,primary_ext,blurb\nx,y,z\n";
        beforeEach(done => {
          setupWithCsv(csvValid)
            .then(inputReference)
            .then(done);
        });

        it('is disabled', () => {
          expect($("#bulk-submit-button")).toBeDisabled();
        });
      });

      describe('there are unresolved matches', () => {

        beforeEach(done => {
          setupWithCsv(csvValid)
            .then(inputReference)
            .then(done);
        });

        it('is disabled', () => {
          expect($("#bulk-submit-button")).toBeDisabled();
        });
      });

      describe('there are no invalid fields or unresolved matches', () => {

        beforeEach(done => {
          setupWithCsv(csvValidNoMatches)
            .then(inputReference)
            .then(done); 
        });

        it ('is enabled', () => {
          expect($("#bulk-submit-button")).not.toBeDisabled();
        });
      });
    });

    describe('handling submission', () => {

      const emptyPromise = Promise.resolve([]);

      describe('table has only new entities', () => {

        const entities = fxt.newEntities;

        describe('on submit', () => {

          beforeEach(done =>  {
            appendSpinnerSpy = spyOn(utility, 'appendSpinner');
            setupSubmit(entities, emptyPromise, emptyPromise)
              .then(done);
          });

          it('attempts to create new entities', () => {
            expect(createEntitiesSpy).toHaveBeenCalledWith(Object.values(fxt.newEntities));
          });

          it('replaces the submit button with a spinner during API call', () => {
            expect(appendSpinnerSpy).toHaveBeenCalled();
          });

          it('restores the submit button after API call', () => {
            expect($("#bulk-submit-button")).toExist();
          });
        });

        describe('creating new entities fails', () => {

          beforeEach(done => {
            errorMsg = "Could not create new entities: request formatted improperly";
            setupSubmit(
              entities,
              Promise.reject(errorMsg),
              emptyPromise
            ).then(done);
          });

          it('displays error message in notifications bar', () => {
            expect($("#notifications")).toHaveText(errorMsg);
          });
        });

        describe('creating new entities succeeds', () => {

          beforeEach(done => {
            setupSubmit(
              entities,
              Promise.resolve(fxt.createdEntitiesParsed),
              emptyPromise
            ).then(done);
          });

          it('stores ids for newly created entities in store', () => {
            expect(bulkTable.getIn(['entities', 'byId'])).toEqual({
              1: fxt.createdEntitiesParsed[0],
              2: fxt.createdEntitiesParsed[1]
            });
            expect(bulkTable.getIn(['entities', 'order'])).toEqual(["1", "2"]);
          });

          it('displays newly created entities in table', () => {
            expect(findFirstRow().find('td.name input'))
              .toHaveValue(fxt.createdEntitiesParsed[0].name);
            expect(findSecondRow().find('td.name input')).
              toHaveValue(fxt.createdEntitiesParsed[1].name);
          });

          it('tries to associate entities with list', () => {
            expect(addEntitiesToListSpy).toHaveBeenCalledWith('1', ['1', '2'], reference);
          });
        });

        describe('associating entities with list fails', () => {

          beforeEach(done => {
            errorMsg = "Could not create add entities to list: invalid reference";
            setupSubmit(
              newEntities,
              Promise.resolve(fxt.createdEntitiesParsed),
              Promise.reject(errorMsg)
            ).then(done);
          });

          it('displays error message in notifications bar', () => {
            expect($("#notifications")).toHaveText(errorMsg);
          });

          it('does not redirect', () => {
            expect(redirectSpy).not.toHaveBeenCalled();
          });
        });

        describe('associating entities with list succeeds', () => {

          beforeEach(done => {
            setupSubmit(
              entities,
              Promise.resolve(fxt.createdEntitiesParsed),
              Promise.resolve(fxt.listEntitiesParsed)
            ).then(done);
          });

          it('redirects to list members tab', () => {
            expect(redirectSpy).toHaveBeenCalledWith('/lists/1');
          });
        });
      });

      describe('table has no new entities', () => {

        beforeEach(() => setupSubmit(fxt.existingEntities, emptyPromise, emptyPromise));

        it('does not attempt to create new entities', () => {
          expect(createEntitiesSpy).not.toHaveBeenCalled();
        });
      });

      describe('table has some new entities, some matched entities', () => {

        beforeEach(() => setupSubmit(fxt.newAndExistingEntities, emptyPromise, emptyPromise));

        it('only tries to create new entities', () => {
          const newEntity = fxt.newAndExistingEntities.newEntity0;
          expect(createEntitiesSpy).toHaveBeenCalledWith([newEntity]);
        });
      });
    });
  });

  describe('empty table', () => {
    beforeEach(() => bulkTable.init(defaultState()));

    it('does not exist', () =>{
      expect($('#test-dom table#bulk-add-table')).not.toExist();
    });
  });
});
