// const testDom = '<div id="test-dom"></div>';

// beforeEach(function(){
//   $('body').append(testDom);
//   entity.editableBlurb();
// });

// afterEach(function(){
//   $('#test-dom').remove();
// });

describe('relationshipsDatatable', function() {
  describe('createTable()', () => {
    const table = RelationshipsDatatable._createTable();

    it('sets class and id', () => {
      expect(table.id).toEqual('relationships-table');
      expect(table.className).toEqual('relationships-datatable-table display');
    });

    it('has a header for each column', () => {
      expect(table.querySelectorAll('thead th').length)
	.toEqual(RelationshipsDatatable._columns.length);
    });
  });
});
