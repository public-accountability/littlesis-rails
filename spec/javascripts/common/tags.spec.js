describe('tag module', function () {

  var allTags = [{
    name: 'Oil',
    description: 'flows from pipes',
    id: 1
  },{
    name: 'NYC',
    description: 'center of the universe!',
    id: 2
  }];
  
  describe('construction', function (){
    
    it('creates a tags data structure from input', function(){
      tags.init(allTags, [1]);
      expect(tags.get()).toEqual({
	all: allTags,
	current: [1]
      });
    });
  });
  
  describe('displaying tags', function(){
    
    it('shows all the tags given for a page');

  });

  describe('editing tags', function(){

    it('shows an x inside tags that a user can remove');

    it('does not show an x inside tags that a user cannot remove');

    it('displays whitelisted tags for user to pick from');

    it('does not allow user to enter tags that are not whitelisted');

    it('stretches the bounding box to contain multiple rows of tags');  

    it('submits new tags when user clicks button');
  });
});
