fdescribe('Bulk Table module', () => {

  // mutable variables used as hooks in setup steps
  let searchEntityStub, hasFileSpy, getFileSpy, file;

  // millis to wait for search, csv upload, etc...
  // tune this if you are getting
  // odd non-deterministic failures due to async issues
  const asyncDelay = 5;

  // CELL FIXTURES
  // (would be better to import constant from `bulkTable.js`, but we don't have modules)

  const columns = [{
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

  // ID FIXTURES (to avoid "magic ids")

  const ids = {
    uploadButton:  "bulk-add-upload-button",
    notifications: "bulk-add-notifications"
  };

  // ENITY FIXTURES

  const entities = {
    newEntity0: {
      id:          "newEntity0",
      name:        "Lew Basnight",
      primary_ext: "Person",
      blurb:       "Adjacent to the invisible"
    },
    newEntity1: {
      id:          "newEntity1",
      name:        "Chums Of Chance",
      primary_ext: "Org",
      blurb:       "Do not -- strictly speaking -- exist"
    }
  };

  // CSV FIXTURE

  const csvValid =
        "name,primary_ext,blurb\n" +
        `${entities.newEntity0.name},${entities.newEntity0.primary_ext},${entities.newEntity0.blurb}\n` +
        `${entities.newEntity1.name},${entities.newEntity1.primary_ext},${entities.newEntity1.blurb}\n`;

  const csvValidNoMatches =
        "name,primary_ext,blurb\n" +
         `${entities.newEntity1.name},${entities.newEntity1.primary_ext},${entities.newEntity1.blurb}\n`;

  // DOM/STATE FIXTURES

  const testDom ='<div id="test-dom"></div>';

  const defaultState = {
    rootId:   "test-dom",
    endpoint: "/lists/1/new_entities"
  };

  // HELPERS

  const setupWithCsv = (csv, done) => {
    file = new File([csv], "test.csv", {type: "text/csv"});
    hasFileSpy.and.returnValue(true);
    getFileSpy.and.returnValue(file);
    bulkTable.init(defaultState);
    $(`#${ids.uploadButton}`).change();
    setTimeout(done, 2 * asyncDelay); // wait for file to upload, etc.
  };

  const setupEdit = (csv, findCell, value, done, clickable = '.cell-contents') => {
    // needed to accomodate multiple async calls in setup step
    // not pretty, but it works!
    // TODO: modify `setupWithCsv` to return a promise so we could chain `thens` here...
    setupWithCsv(csvValid, () =>  {
      setTimeout(() => {
        editCell(findCell(), clickable, value);
        setTimeout(done, asyncDelay);
      }, asyncDelay);
    });
  };

  const searchEntityFake = query => {
    // stub search api call w/ 1 successful, 1 failed result
    switch(query){
    case entities.newEntity0.name:
      return Promise.resolve(searchResultsFor(entities.newEntity0));
    default:
      return Promise.resolve([]);
    }
  };

  const searchResultsFor = entity => [0,1,2].map(n => {
    const ext = ["Org", "Person"][n % 2];
    return {
      id:          `${n}${entity.id.slice(-1)}`,
      name:        `${entity.name} dupe name ${n}`,
      blurb:       `dupe description ${n}`,
      primary_ext:  ext,
      url:         `/${ext.toLowerCase()}/${n}/${entity.name.replace(" ", "")}`
    };
  });

  const editCell = (cell, clickable, newValue) => {
    cell.find(clickable).trigger('click');
    cell.find('.edit-cell')
      .val(newValue)
      .trigger('change')
      .trigger($.Event('keyup', { keyCode: 13 }));
  };

  const findFirstRow = () => $("#bulk-add-table tbody tr:nth-child(1)");
  const findSecondRow = () => $("#bulk-add-table tbody tr:nth-child(2)");

  // SETUP
  
  beforeEach(() => {
    hasFileSpy = spyOn(bulkTable, 'hasFile');
    getFileSpy = spyOn(bulkTable, 'getFile');
    searchEntityStub = spyOn(api, 'searchEntity').and.callFake(searchEntityFake);
    $('body').append(testDom);
  });

  afterEach(() => { $('#test-dom').remove(); });

  describe('initialization', () => {

    beforeAll(() => bulkTable.init(defaultState));

    it('stores a reference to its root node', () => {
      expect(bulkTable.get('rootId')).toEqual('test-dom');
    });

    it('stores an endpoint', () => {
      expect(bulkTable.get('endpoint')).toEqual("/lists/1/new_entities");
    });

    it('initializes an empty entities state tree', () =>{
      expect(bulkTable.get('entities')).toEqual({
        byId:    {},
        order:   [],
        matches: {},
        errors:  {}
      });
    });

    describe('detecting upload support', () => {

      let browserCanOpenFilesSpy;

      describe("when browser can open files", () => {

        beforeEach(() => {
          browserCanOpenFilesSpy = spyOn(utility, 'browserCanOpenFiles').and.returnValue(true);
          bulkTable.init(defaultState);
        });

        it('shows an upload button', () => {
          expect($(`#${ids.uploadButton}`)).toExist();
        });
      });

      describe('when browser cannot open files', () => {

        beforeEach(() => {
          browserCanOpenFilesSpy = spyOn(utility, 'browserCanOpenFiles').and.returnValue(false);
          bulkTable.init(defaultState);
        });

        it('hides the upload button', () => {
          expect($(`#${ids.uploadButton}`)).not.toExist();
        });

        it('displays an error message', () => {
          expect($(`#${ids.notifications}`).html()).toMatch('Your browser');
        });
      });
    });
  });

  describe('uploading csv', () => {

    describe("with well-formed csv", () => {

      beforeEach(done => setupWithCsv(csvValid, done));

      it('stores entity data', () => {
        expect(bulkTable.getIn(['entities', 'byId'])).toEqual({
          newEntity0: entities['newEntity0'],
          newEntity1: entities['newEntity1']
        });
      });

      it('stores row ordering', () => {
        expect(bulkTable.getIn(['entities', 'order'])).toEqual(Object.keys(entities));
      });

      it('hides upload button', () => {
        expect($(`#${ids.uploadButton}`)).not.toExist();
      });
    });

    describe('with invalid header fields', () => {

      const csvInvalidHeaders = "foo,bar\nbaz,bam\n";
      beforeEach(done => setupWithCsv(csvInvalidHeaders, done));

      it('does not store csv data', () => {
        expect(bulkTable.getIn(['entities', 'byId'])).toEqual({});
      });

      it('displays an error message', () => {
        expect($("#bulk-add-notifications")).toContainText("Invalid headers");
      });

      it('still shows upload button', () => {
        expect($(`#${ids.uploadButton}`)).toExist();
      });
    });

    describe('with incorrectly formatted csv', () => {

      const csvInvalidShape = "name,primary_ext,blurb\nfoo,bar\n";
      beforeEach(done => setupWithCsv(csvInvalidShape, done));

      it('does not store csv data', () => {
        expect(bulkTable.getIn(['entities', 'byId'])).toEqual({});
      });

      it('displays an error message', () => {
        var notification = $("#bulk-add-notifications").text();
        expect($("#bulk-add-notifications")).toContainText("CSV format error");
      });

      it('still shows upload button', () => {
        expect($(`#${ids.uploadButton}`)).toExist();
      });
    });

    describe('re-submitting valid csv after an invalid upload', () => {

      beforeEach(done => {
        setupWithCsv("foobar", () => null);
        getFileSpy.and.returnValue(new File([csvValid], "_.csv", { type: "text/csv"} ));
        $(`#${ids.uploadButton}`).change();
        setTimeout(done, asyncDelay);
      });

      it('clears the error message', () => {
        expect($("bulk-add-notifications")).not.toExist();
      });

      it('hides the upload button', () => {
        expect($(`#${ids.uploadButton}`)).not.toExist();
      });
    });
  });

  describe('table layout', () => {

    beforeEach(done => setupWithCsv(csvValid, done));

    it('exists', () => {
      expect($('#test-dom table#bulk-add-table')).toExist();
    });

    it('has columns labeling entity fields', () => {
      const thTags = $('#bulk-add-table thead tr th').toArray();
      expect(thTags).toHaveLength(3);
      thTags.forEach((th, idx) => expect(th).toHaveText(columns[idx].label));
    });

    it('has rows showing values of entity fields', () => {
      const rows = $('#bulk-add-table tbody tr').toArray();
      expect(rows).toHaveLength(2);
      rows.forEach((row, idx) => {
        expect(row.textContent).toEqual( // row.textContent concatenates all cell text with no spaces
          columns.map(col => entities[`newEntity${idx}`][col.attr] ).join("")
        );
      });
    });

    it('has a submit button', () => {
      expect($("#bulk-submit-button")).toExist();
      expect($("#bulk-submit-button")).toHaveText("Submit");
    });
  });

  describe('entity resolution', () => {

    beforeEach(done => setupWithCsv(csvValid, done));

    describe('search', () => {

      it('searches littlesis for entities with same name as user submissions', () => {
        expect(searchEntityStub).toHaveBeenCalledWith(entities.newEntity0.name);
        expect(searchEntityStub).toHaveBeenCalledWith(entities.newEntity1.name);
      });

      it('stores list of search matches in memory', () => {
        expect(bulkTable.getIn(['entities', 'matches'])).toEqual({
          newEntity0: {
            byId:     utility.normalize(searchResultsFor(entities.newEntity0)),
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

      it('displays alert icons next to rows with search matches', () => {
        expect(findFirstRow().find(".resolver-anchor")).toExist();
      });

      it('does not display alert icons next to rows with no search matches', () => {
        expect(findSecondRow().find(".resolver-anchor")).not.toExist();
      });

      it('shows a popover when user clicks on alert icon', () => {
        findFirstRow().find('.resolver-anchor').trigger('click');
        expect(findFirstRow().find(".resolver-popover")).toExist();
      });
    });

    describe('popover', () => {

      let popover;
      const matches = searchResultsFor(entities.newEntity0);

      beforeEach(done => {
        findFirstRow().find(".resolver-anchor").trigger('click');
        popover = findFirstRow().find(".resolver-popover");
        setTimeout(done, asyncDelay);
      });

      it('has a title', () => {
        expect(findFirstRow().find(".popover-title")).toHaveText("Similar entities already exist!");
      });

      it('has a selectpicker with all matched entities', () => {
        matches.forEach(match => {
          expect(findFirstRow().find(".resolver-selectpicker")).toContainText(match.name);
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
          expect(bulkTable.getIn(['entities', 'matches', 'newEntity0', 'selected']))
            .toEqual(matches[0].id);
        });

        it('shows a section about user selection below the picker', () => {
          expect(popover.find(".resolver-picker-result-container")).toContainElement(".resolver-picker-result");
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

        it('closes the popover', () => {
          expect(findFirstRow().find(".resolver-popover")).not.toExist();
        });

        it('removes the alert icon next to the row', () => {
          expect(findFirstRow().find(".resolver-anchor")).not.toExist();
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

    describe('contents of a valid cell', () => {

      const findCell = () => findFirstRow().find('td:nth-child(3)');
      beforeEach(done => setupEdit(csvValid, findCell, 'foobar', done));

      it('updates cell', () => {
        expect(findCell()).toContainText('foobar');
      });

      it('updates store', () => {
        expect(bulkTable.getIn(['entities', 'byId', 'newEntity0', 'blurb']))
          .toEqual('foobar');
      });
    });

    describe('contents of an invalid cell', () => {

      const csv = "name,primary_ext,blurb\nvalid name,x,y\n";
      const findCell = () => findFirstRow().find('td:nth-child(2)');
      beforeEach(done => setupEdit(csv, findCell, 'Person', done));

      it('updates cell', () => {
        expect(findCell()).toHaveText('Person');
      });

      it('updates store', () => {
        expect(bulkTable.getIn(['entities', 'byId', 'newEntity0', 'primary_ext']))
          .toEqual('Person');
      });
    });

    describe('contents of name cell', () => {

      const findCell = () => findSecondRow().find('td:nth-child(1)');
      beforeEach(done => setupEdit(csvValid, findCell, entities.newEntity0.name, done));

      it('searches for entities matching new name', () => {
        expect(searchEntityStub).toHaveBeenCalledWith(entities.newEntity0.name);
        expect(bulkTable.getIn(['entities', 'matches', 'newEntity1'])).toExist();
        expect(findSecondRow().find(".resolver-anchor")).toExist();
      });
    });
  });

  describe('validation', () => {

    describe('rules', () => {

      const validEntity = {
        id:          'fakeId',
        name:        'ValidName',
        primary_ext: 'Org',
        blurb:       'valid blurb'
      };

      const baseEntitiesState = {
        byId:    {},
        order:   [],
        matches: {},
        errors:  {}
      };

      const stateOf = (entitySpec) => Object.assign({}, defaultState, {
        entities: Object.assign({}, baseEntitiesState, {
          byId: { fakeId: Object.assign({}, validEntity, entitySpec) }
        })
      });

      const errorsFor =(entitySpec) =>
            bulkTable
            .init(stateOf(entitySpec))
            .validate()
            .getIn([ 'entities', 'errors', 'fakeId']);

      it('handles a valid entity', () => {
        expect(errorsFor(validEntity)).toEqual({});
      });

      it('does not require a blurb', () => {
        expect(errorsFor({ blurb: '' })).toEqual({});
      });

      it('requires a name', () => {
        expect(errorsFor({ name: "" })).toEqual({
          name:        ['is required', 'must be at least 2 characters long']
        });
      });

      it('requires a name be at least two characters', () => {
        expect(errorsFor({ name: "x" })).toEqual({
          name:        ['must be at least 2 characters long']
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
          name:        ['must have a first and last name']
        });
      });

      it('handles multiple simultaneous errors', () => {
        expect(errorsFor({ primary_ext: "", name:"" })).toEqual({
          name:        ['is required', 'must be at least 2 characters long'],
          primary_ext: ['is required', 'must be either "Person" or "Org"']
        });
      });
    });

    describe('showing error alerts', () => {
      const csv = "name,primary_ext,blurb\nx,y,z\n";
      beforeEach(done => setupWithCsv(csv, done));

      it('highlights cell if name is not valid', () => {
        const cell = findFirstRow().find('td:nth-child(1)');
        expect(cell).toHaveClass("errors");
        expect(cell.find(".error-alert")).toExist();
      });

      it('highlights cell if primary extension is not valid', () => {
        const cell = findFirstRow().find('td:nth-child(2)');
        expect(cell).toHaveClass("errors");
        expect(cell.find(".error-alert")).toExist();
      });

      it('shows tooltip with error message when user mouses over cell', () => {
        const cell = findFirstRow().find('td:nth-child(1)');
        cell.find('.error-alert').trigger('mouseover');
        expect(cell.find('.tooltip')).toContainText('[ ! ] Name must be');
      });
    });

     describe('removing error alerts', () => {

      const csv = "name,primary_ext,blurb\nx,y,z\n";

      describe('in a name field', () => {
        const findCell = () => findFirstRow().find('td:nth-child(1)');
        beforeEach(done => setupEdit(csv, findCell , 'Valid Name', done, '.error-alert'));

        it('removes alert after name error is fixed', () => {
          editCell(findCell(), '.error-alert', 'Valid Name');
          expect(findCell()).not.toHaveClass("errors");
        });
      });

      describe('in a primary_ext field', () => {
        const findCell = () => findFirstRow().find('td:nth-child(2)');
        beforeEach(done => setupEdit(csv, findCell , 'Person', done, '.error-alert'));

        it('removes alert after name error is fixed', () => {
          editCell(findCell(), '.error-alert', 'Valid Name');
          expect(findCell()).not.toHaveClass("errors");
        });
      });
    });
  });

  describe('submitting', () => {

    describe('there are invalid fields', () => {

      const csv = "name,primary_ext,blurb\nx,y,z\n";
      beforeEach(done => setupWithCsv(csv, done));

      it('will not submit', () => {
        expect($("#bulk-submit-button")).toBeDisabled();
      });
    });

    describe('there are unresolved matches', () => {

      beforeEach(done => setupWithCsv(csvValid, done));

      it('will not submit', () => {
        expect($("#bulk-submit-button")).toBeDisabled();
      });
    });

    describe('there are no invalid fields or unresolved matches', () => {

      beforeEach(done => setupWithCsv(csvValidNoMatches, done));

      it ('can submit', () => {
        expect($("#bulk-submit-button")).not.toBeDisabled();
      });

      it('submits a batch of entities to a list endpoint');

      describe('all submissions worked', () => {
        it('redirects to list members tab');
      });

      describe('some submissions failed', () => {
        it('deletes successful submissions from the store');
        it('marks failed submissions with error messages');
        it('renders table with only failed submissions');
      });
    });
  });

  describe('empty table', () => {
    beforeEach(() => bulkTable.init(defaultState));

    it('does not exist', () =>{
      expect($('#test-dom table#bulk-add-table')).not.toExist();
    });
  });
});
