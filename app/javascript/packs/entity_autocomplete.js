export default function EntityAutocomplete({config}){

  this.prepare = function(){
    $(config['input_id']).typeahead(null, {
      async: true,
      name: 'entities',
      source: entitySearch,
      limit: 8,
      display: 'name',
      templates: {
        empty: $(config['templates']['empty_message']).html(),
        suggestion: function(data) {
          return mustache.render($(config['templates']['entity_suggestion']).html(), data)
        }
      }
    })

    $(config['input_id']).bind('typeahead:select', function(ev, suggestion) {
      submitEntity(suggestion.id);
    })
  };

  const form = function(entity_id) {
    let template = $($(config['templates']['form']).html());
    let action = template.attr('action').replace(/XXX/, entity_id);
    template.attr('action', action);
    template.children('[name=entity_id]').val(entity_id)

    $(document.body).append(template);
    return template;
  };

  const submitEntity = function(entity_id) {
    form(entity_id).submit();
  }

  const entitySearch = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: config['query_path'],
      wildcard: '%QUERY'
    }
  });
}
