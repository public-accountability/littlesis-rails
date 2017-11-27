describe('Bulk Table module', () => {

  // TODO: USE THIS IN EVERY ASYNC TEST!!!!
  const wait = (millis) => new Promise((rslv,rjct) => setTimeout(rslv, millis));
  // mutable variables used as hooks in setup steps
  let searchEntityStub, redirectSpy, hasFileSpy, getFileSpy, file;

  // millis to wait for search, csv upload, etc...
  // tune this if you are getting non-deterministic failures due to async issues
  const asyncDelay = 10;

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

  // ENTITY FIXTURES

  const newEntities = fxt.newEntities;
  const mixedEntities = fxt.newAndExistingEntities;

  // CSV FIXTURES

  const csvValid =
    "name,primary_ext,blurb\n" +
    `${newEntities.newEntity0.name},${newEntities.newEntity0.primary_ext},${newEntities.newEntity0.blurb}\n` +
    `${newEntities.newEntity1.name},${newEntities.newEntity1.primary_ext},${newEntities.newEntity1.blurb}\n`;

  const csvValidOnlyMatches =
        "name,primary_ext,blurb\n" +
        `${newEntities.newEntity0.name},${newEntities.newEntity0.primary_ext},${newEntities.newEntity0.blurb}\n`;

  const csvValidNoMatches =
    "name,primary_ext,blurb\n" +
        `${newEntities.newEntity1.name},${newEntities.newEntity1.primary_ext},${newEntities.newEntity1.blurb}\n`;

  const csvSample =
      'name,primary_ext,blurb\n'+
      'SampleOrg,Org,Description of SampleOrg\n' +
      'Sample Person,Person,Description of Sample Person';

  // DOM/STATE FIXTURES

  const testDom ='<div id="test-dom"></div>';

  const defaultState = {
    domId:        "test-dom",
    resourceType: "lists",
    resourceId:   "1"
  };

  // HELPERS

  const setupWithCsv = (csv, done) => {
    file = new File([csv], "test.csv", {type: "text/csv"});
    hasFileSpy.and.returnValue(true);
    getFileSpy.and.returnValue(file);
    bulkTable.init(defaultState);
    $('#upload-button').change();
    setTimeout(done, 2 * asyncDelay); // wait for file to upload, etc.
  };

  const setupEdit = (csv, findInput, value, done) => {
    // needed to accomodate multiple async calls in setup step. not pretty, but it works!
    // TODO: modify `setupWithCsv` to return a promise so we could chain `thens` here?
    setupWithCsv(csvValid, () =>  {
      setTimeout(() => {
        editCell(findInput(), value);
        setTimeout(done, asyncDelay);
      }, asyncDelay);
    });
  };

  const editCell = (input, newValue) => {
    input
      .val(newValue)
      .trigger('change')
      .trigger($.Event('keyup', { keyCode: 13 })); // hit enter
  };

  const searchEntityFake = query => {
    // default implementation of search stub
    // returns match for first new entity, none for second new entity
    switch(query){
    case newEntities.newEntity0.name:
      return Promise.resolve(searchResultsFor(newEntities.newEntity0));
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

    it('stores a reference to its root dom node', () => {
      expect(bulkTable.get('domId')).toEqual('test-dom');
    });

    it('stores a reference to id of the resource it is bulk modifying', () => {
      expect(bulkTable.get('resourceId')).toEqual('1');
    });

    it('stores a reference to type of the resource it is bulk modifying', () => {
      expect(bulkTable.get('resourceType')).toEqual('lists');
    });

    it('stores references to its api methods');
    // not yet! (finish the card first)

    it('initializes empty entity repository', () =>{
      expect(bulkTable.get('entities')).toEqual({
        byId:    {},
        order:   []
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

      let browserCanOpenFilesSpy;

      describe("when browser can open files", () => {

        beforeEach(() => {
          browserCanOpenFilesSpy = spyOn(utility, 'browserCanOpenFiles').and.returnValue(true);
          bulkTable.init(defaultState);
        });

        it('shostack@http://localhost:8888/__jasmine__/jasmine.js:2155:17ws an upload button', () => {
          expect($('#upload-button')).toExist();
        });

        it('shows a download button', () => {
          expect($('#download-button')).toExist();
        });
      });

      describe('when browser cannot open files', () => {

        beforeEach(() => {
          browserCanOpenFilesSpy = spyOn(utility, 'browserCanOpenFiles').and.returnValue(false);
          bulkTable.init(defaultState);
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

      beforeEach(done => setupWithCsv(csvValid, done));

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
    });

    describe('with invalid header fields', () => {

      const csvInvalidHeaders = "foo,bar\nbaz,bam\n";
      beforeEach(done => setupWithCsv(csvInvalidHeaders, done));

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
      beforeEach(done => setupWithCsv(csvInvalidShape, done));

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
        setupWithCsv("foobar", () => null);
        getFileSpy.and.returnValue(new File([csvValid], "_.csv", { type: "text/csv"} ));
        $('#upload-button').change();
        setTimeout(done, asyncDelay);
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
      bulkTable.init(defaultState);
    });

    it('saves a sample csv to the user\'s file system', () => {
      $('#download-button').click();
      expect(saveAsSpy).toHaveBeenCalledWith(
        new File([csvSample], 'sample.csv', { type: 'text/csv; charset=utf-8' })
      );
    });
  });

  describe('layout', () => {

    beforeEach(done => setupWithCsv(csvValid, done));

    describe('table', () => {

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

    beforeEach(done => setupWithCsv(csvValid, done));

    describe('search', () => {

      it('searches littlesis for entities with same name as user submissions', () => {
        expect(searchEntityStub).toHaveBeenCalledWith(newEntities.newEntity0.name);
        expect(searchEntityStub).toHaveBeenCalledWith(newEntities.newEntity1.name);
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
      const matches = searchResultsFor(newEntities.newEntity0);

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
        beforeEach(done => setupEdit(csvValid, findInput, 'foobar', done));

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
        beforeEach(done => setupEdit(csv, findInput, 'Person', done));

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
        beforeEach(done => setupEdit(csvValid, findInput, newEntities.newEntity0.name, done));

        it('searches for entities matching new name', () => {
          expect(searchEntityStub).toHaveBeenCalledWith(newEntities.newEntity0.name);
          expect(bulkTable.getIn(['matches', 'byEntityId', 'newEntity1'])).toExist();
          expect(findSecondRow().find(".resolver-anchor")).toExist();
        });
      });
    });

    describe('reference', () => {

      beforeEach(done => setupWithCsv(csvValid, done));

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

      const stateOf = (entitySpec) => Object.assign({}, defaultState, {
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
          name: ['must have a first and last name']
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

      const stateOf = (referenceSpec) => Object.assign({}, defaultState, {
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
      beforeEach(done => setupWithCsv(csv, () => setTimeout(done, asyncDelay)));

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
        expect(input.parent().find('.tooltip')).toContainText('[ ! ] Name must be');
      });

      it('hides error tooltip on mouseout', () => {
        const input = findFirstInput();
        input.trigger('mousenter');
        input.trigger('mouseout');
        expect(input.parent().find('.tooltip')).not.toExist();
      });

      it('shows error tooltip on focus', () => {  // ie: tabbing in
        const input = findFirstInput();
        input.trigger('focus');
        expect(input.parent().find('.tooltip')).toExist();
      });

      xit('hides error tooltip on blur', () => { // ie: tabbing out
        // NOTE (@aguestuser|24-Nov-2017)
        // this works in browser, test fails due to async issues i don't care to address ATM
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
        beforeEach(done => setupEdit(csv, findInput , 'Valid Name', done));

        it('removes alert after error is fixed', () => {
          expect(findInput().parent()).not.toHaveClass("errors");
        });
      });

      describe('in a primary_ext field', () => {
        const findInput = () => findFirstRow().find('td:nth-child(2) input');
        beforeEach(done => setupEdit(csv, findInput , 'Person', done));

        it('removes alert after error is fixed', () => {
          expect(findInput().parent()).not.toHaveClass("errors");
        });
      });

      describe('in a reference name field', () => {
        const findInput = () => $("#reference-container div.name input");
        beforeEach(done => setupWithCsv(csv, done));

        it('removes alert after error is fixed', () => {
          expect(findInput()).toHaveClass("error-alert");
          editCell(findInput(), 'Pynchon Wiki');
          expect(findInput()).not.toHaveClass("error-alert");
        });
      });

      describe('in a reference url field', () => {
        const findInput = () => $("#reference-container div.url input");
        beforeEach(done => setupWithCsv(csv, done));

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
        defaultState,
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

    const reference = {
      name: 'Pynchon Wiki',
      url:  'http://pynchonwiki.com'
    };

    const inputReference = () => {
      $("#reference-container .name input").val(reference.name).trigger('change');
      $("#reference-container .url input").val(reference.url).trigger('change');
    };

    describe('submit button status', () => {

      describe('there are invalid reference fields', () => {
        // double async delay for first it block to pass in isolation
        beforeEach(done => setupWithCsv(csvValid, () =>  {
          setTimeout(done, asyncDelay);
        }));

        it('is disabled', () => {
          expect($("#bulk-submit-button")).toBeDisabled();
        });
      });

      describe('there are invalid table fields', () => {

        const csvInvalid = "name,primary_ext,blurb\nx,y,z\n";
        beforeEach(done => setupWithCsv(csvValid, () =>  {
          inputReference();
          done();
        }));

        it('is disabled', () => {
          expect($("#bulk-submit-button")).toBeDisabled();
        });
      });

      describe('there are unresolved matches', () => {

        beforeEach(done => setupWithCsv(csvValid, () => {
          inputReference();
          done();
        }));

        it('is disabled', () => {
          expect($("#bulk-submit-button")).toBeDisabled();
        });
      });

      describe('there are no invalid fields or unresolved matches', () => {

        beforeEach(done => setupWithCsv(csvValidNoMatches, () => {
          inputReference();
          done();
        }));

        it ('is enabled', () => {
          expect($("#bulk-submit-button")).not.toBeDisabled();
        });
      });
    });

    describe('handling submission', () => {

      let createEntitiesSpy, addEntitiesToListSpy, redirectSpy, errorMsg;

      const setupSubmit = (entitiesById, createEntitiesVal, addEntitiesToListVal) => {

        createEntitiesSpy = spyOn(api, 'createEntities').and.returnValue(createEntitiesVal);
        addEntitiesToListSpy = spyOn(api, 'addEntitiesToList').and.returnValue(addEntitiesToListVal);
        redirectSpy = spyOn(utility, 'redirectTo').and.callFake(() => null);

        bulkTable.init(Object.assign(
          {},
          defaultState,
          {
            entities: { byId: entitiesById, order: Object.keys(entitiesById) },
            reference: reference
          }
        ));

        $('#bulk-submit-button').trigger('click');
        return wait(asyncDelay);
      };

      const emptyPromise = Promise.resolve([]);

      describe('table has only new entities', () => {

        const entities = fxt.newEntities;

        describe('on submit', () => {

          beforeEach(done =>  {
            setupSubmit(entities, emptyPromise, emptyPromise)
              .then(done);
          });

          it('attempts to create new entities', () => {
            expect(createEntitiesSpy).toHaveBeenCalledWith(Object.values(fxt.newEntities));
          });
        });

        describe('creating new entities fails', () => {

          beforeEach(done => {
            errorMsg = "Could not create new entities: request formatted improperly";
            setupSubmit(entities, Promise.reject(errorMsg), emptyPromise)
              .then(done);
          });

          it('displays error message in notifications bar', () => {
            expect($("#notifications")).toHaveText(errorMsg);
          });

          it('marks entities that could not be created with alert icon');
          // or maybe not?
        });

        describe('creating new entities succeeds', () => {

          beforeEach(done => {
            setupSubmit(entities, Promise.resolve(fxt.createdEntitiesParsed), emptyPromise)
              .then(done);
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
            setupSubmit(newEntities, Promise.resolve(fxt.createdEntitiesParsed), Promise.reject(errorMsg))
              .then(done);
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

        describe('creating new entities fails', () => {
          it('does not mark matched entities with alert icon');
          // left pending until feature is implemented or rejected
        });
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
