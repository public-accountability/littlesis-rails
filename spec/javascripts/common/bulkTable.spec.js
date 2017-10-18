describe('Bulk Table module', () => {


  const entities = {
    0: {
      name: "Lew Basnight",
      primary_ext: "Person",
      blurb: "Adjacent to the invisible"
    },
    1: {
      name: "Chums Of Chance",
      primary_ext: "Org",
      blurb: "Do not -- strictly speaking -- exist"
    }
  };

  const csv =
        "name,primary_ext,blurb\n" +
        `${entities[0].name},${entities[0].primary_ext},${entities[0].blurb}\n` +
        `${entities[1].name},${entities[1].primary_ext},${entities[1].blurb}\n`;

  const uploadButtonId = "csv-upload-button";

  const testDom =
        '<div id="test-dom">' +
          `<div id="${uploadButtonId}-container">` +
            `<input type="file" id="${uploadButtonId}">` +
          '</div>' +
        '</div>';
  
  const defaultState = {
    rootId: "test-dom",
    uploadButtonId: uploadButtonId
  };

  beforeEach(() => { $('body').append(testDom); });
  afterEach(() => { $('#test-dom').remove(); });

  describe('initialization', () => {

    let onUploadSpy, browserCanOpenFilesSpy;

    beforeEach(() => onUploadSpy = spyOn(bulkTable, 'onUpload'));

    describe('in all cases', () => {

      beforeAll(() => bulkTable.init(defaultState));

      it('stores a reference to its root node', () => {
        expect(bulkTable.get('rootId')).toEqual('test-dom');
      });

      it('stores a reference to the upload button', () => {
        expect(bulkTable.get('uploadButtonId')).toEqual('csv-upload-button');
      });
    });
    
    describe("when browser can open files", () => {
      
      beforeEach(() => {
        browserCanOpenFilesSpy = spyOn(utility, 'browserCanOpenFiles').and.returnValue(true);
        bulkTable.init(defaultState);
      });

      it('registers file upload handler', () => {
        expect(onUploadSpy).toHaveBeenCalledWith(
          uploadButtonId,
          bulkTable.parseEntities
        );
      });
    });

    describe('when browser cannot open files', () => {

      beforeEach(() => {
        browserCanOpenFilesSpy = spyOn(utility, 'browserCanOpenFiles').and.returnValue(false);
        bulkTable.init(defaultState);
      });

      it('registers file upload handler', () => {
        expect(onUploadSpy).not.toHaveBeenCalled();
      });

      it('hides the upload button', () => {
        expect($(`#${uploadButtonId}`)).not.toExist();
      });
      
      it('displays an error message', () => {
        expect($(`#${uploadButtonId}-container`).html()).toMatch('Your browser');
      });
    });
  });

  describe('parsing', () => {

    const file = new File([csv], "test.csv", {type: "text/csv"});
    let hasFileSpy, getFileSpy;

    beforeEach(() => {
      hasFileSpy = spyOn(bulkTable, 'hasFile').and.returnValue(true);
      getFileSpy = spyOn(bulkTable, 'getFile').and.returnValue(file);
      bulkTable.init(defaultState);
    });

    it('parses a TableData object from a csv file', done => {
      $(`#${defaultState.uploadButtonId}`).change();
      setTimeout(() => {
        expect(bulkTable.get('entitiesById')).toEqual({
          newEntity0: entities[0],
          newEntity1: entities[1]
        });
        done();
      }, 5); // wait 5 millis for upload to complete
    });
  });

  describe('matching', () => {
    // TODO: new batch endpoint would be nice...
    it('queries LS for pre-existing entities from TableData object');
    it('marks matched entities in TableData object');
    it('stores list of possible matches in TableData row');
    it('allows user to choose to use a matched entitiy or create new entity');

    describe('user chooses matched entity', () => {
      it('marks entity row as matched');
      it('overwrites user-submitted entity fields with matched fields');
      it('stores an id');
    });

    describe('user chooses user-submitted fields', () => {
      it('ignores matched existing entity fields');
    });
  });

  describe('validations', () => {
    // TODO: leave a seam here to extend for different pages...
    it('requires a primary extension be selected');
    it('requires an org name to be at least 1 character long');
    it('requires a person to have a first and last name');
  });

  describe('rendering', () => {

    describe('with no matches', () => {
      it('renders an html table from a TableData object');
      it('re-renders a table row if its contents are edited');
    });

    describe('with matches', () => {
      it('prompts user to use match or create new entity');

      describe('user chooses matched entity', () => {
        it('marks rows with matched entities');
        it('blocks edits to matched entity fields');
      });
    });

    describe('with invalid fields', () => {
      it('marks invalid fields');
    });
  });

  describe('submitting', () => {
    describe('there are invalid fields', () => {
      it('will not submit');
    });

    describe('there are no invalid fields', () => {

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
});
