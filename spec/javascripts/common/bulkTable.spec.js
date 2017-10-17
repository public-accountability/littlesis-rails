describe('Bulk Table module', () => {

  describe('parsing', () => {
    it('reads a csv file into a string');
    it('parses a TableData object from a csv string');
  });

  describe('matching', () => {
    // TODO: new batch endpoint would be nice...
    it('queries LS for pre-existing entities from TableData object');
    it('marks matched entities in TableData object');
    it('stores list of possible matches in TableData row');
    it('allows user to choose to use a matched entitiy or create new entity');

    context('user chooses matched entity', () => {
      it('marks entity row as matched');
      it('overwrites user-submitted entity fields with matched fields');
      it('stores an id');
    });

    context('user chooses user-submitted fields', () => {
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

    context('with no matches', () => {
      it('renders an html table from a TableData object');
      it('re-renders a table row if its contents are edited');
    });

    context('with matches', () => {
      it('prompts user to use match or create new entity');

      context('user chooses matched entity', () => {
        it('marks rows with matched entities');
        it('blocks edits to matched entity fields');
      });
    });

    context('with invalid fields', () => {
      it('marks invalid fields');
    });
  });

  describe('submitting', () => {
    context('there are invalid fields', () => {
      it('will not submit');
    });

    context('there are no invalid fields', () => {

      it('submits a batch of entities to a list endpoint');

      context('all submissions worked', () => {
        it('redirects to list members tab');
      });

      context('some submissions failed', () => {
        it('deletes successful submissions from the store');
        it('marks failed submissions with error messages');
        it('renders table with only failed submissions');
      });
    });
  });
});
