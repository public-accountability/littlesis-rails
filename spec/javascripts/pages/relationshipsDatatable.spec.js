// const testDom = '<div id="test-dom"></div>';

// beforeEach(function(){
//   $('body').append(testDom);
//   entity.editableBlurb();
// });

// afterEach(function(){
//   $('#test-dom').remove();
// });

xdescribe('relationshipsDatatable', function() {
  describe('createTable()', () => {
    const table = RelationshipsDatatable._createTable();

    it('sets class and id', () => {
      expect(table.id).toEqual('relationships-table');
      expect(table.className).toEqual('display');
    });

    it('has a header for each column', () => {
      expect(table.querySelectorAll('thead th').length)
	.toEqual(RelationshipsDatatable._columns.length);
    });
  });

  describe('renderRelatedEntity()', () => {
    const row = {
      "related_entity_name": 'Jane Doe', 
      "related_entity_blurb_excerpt": 'abc',
      "related_entity_url": '/person/1-Jane-Doe'
    };

    const renderedEntity = RelationshipsDatatable._renderRelatedEntity(null, null, row);

    it('has link', () => expect(renderedEntity.includes('/person/1-Jane-Doe')).toBeTrue() );
    it('has excerpt', () => expect(renderedEntity.includes('>abc</span>')).toBeTrue() );
  });
});
