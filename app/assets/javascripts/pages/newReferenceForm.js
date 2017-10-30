/**
 * Widget to select an existing reference or create a new one
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('jQuery'));
  } else {
    root.NewReferenceForm = factory(root.jQuery);
  }
}(this, function ($, utility) {
  var LABEL_CLASS = 'col-sm-2 control-label';
  var INPUT_CLASS = 'form-control text-left';
  var DEFAULT_COL_CLASS = 'col-sm-10';
  var FIELDS_SHOW = [
    [ 'Url*', 'reference-url', 'url' ],
    [ 'Name*', 'reference-name', 'text' ],
  ];
  var FIELDS_COLLAPSE = [
    [ 'Publication Date', 'reference-date', 'text'],
    [ 'Type', 'reference-type', 'select', 'col-sm-6'],
    [ 'Excerpt', 'reference-excerpt', 'textarea' ]
  ];


  /**
   * Form to create a new reference
   *   Use: new NewReferenceForm('#container');
   * @param {String} containerDiv Div to hold the container
   */
  function NewReferenceForm(containerDiv){
    this.containerDiv = containerDiv;
    $(containerDiv).empty();
    render(containerDiv);
  }

  NewReferenceForm.prototype.value = function (){
    return {
      "url": $('#reference-url').val(),
      "name": $('#reference-name').val(),
      "date": $('#reference-date').val(),
      "type": $('#reference-type').val(),
      "excerpt": $("#reference-excerpt").val()
    };
  };

  function render(div) {
    $(div).append(
      $('<div>', { "class": 'form-horizontal'}).append(form())
    );

    $('#collapseReference').on('show.bs.collapse', function(){
      $('.collapse-toggle').toggle();
    });

    $('#collapseReference').on('hide.bs.collapse', function(){
      $('.collapse-toggle').toggle();
    });
  }

  function form() {
    return FIELDS_SHOW.map(fieldHtml)
      .concat(collapse())
      .concat(
	collapseFieldsContainer().append( FIELDS_COLLAPSE.map(fieldHtml))
      );
  }


  function fieldHtml(x) {
    return inputAndLabel(x[0], x[1], x[2], x[3]);
  }

  function inputAndLabel(text, id, type, colClass) {
    return wrapInFormGroup(
      $('<div>')
	.append(label(text, id))
	.append(input(id, type, colClass))
    );
  }

  function wrapInFormGroup(html) {
    return $('<div>',  {"class": 'form-group'}).append(html);
  }

  function label(text, for_attr) {
    return $('<label>', { "class": LABEL_CLASS, "for": for_attr, "text": text });
  }

  function input(id, type, colClass) {
    if (typeof colClass === 'undefined') {
      colClass = DEFAULT_COL_CLASS;
    };

    var div = $('<div>', { "class": colClass});

    if (['url', 'text'].includes(type)) {
      div.append(urlTextInput(id, type));
    } else if (type === 'select') {
      div.append(select());
    } else if (type === 'textarea') {
      div.append(textArea(id));
    }

    return div;
  }

  function urlTextInput(id, type) {
    return $('<input>', { "class": INPUT_CLASS, "type": type, "id": id });
  }

  function select() {
    return [ '<select class="form-control" id="reference-type">',
	     '<option value="1">Generic</option>',
	     '<option value="3">Newspaper</option>',
	     '<option value="4">Government Document</option>',
	     '</select>'
	   ].join('');
  }

  function textArea(id) {
    return $('<textarea>', { "name": id, "id": id, "class": 'form-control', "cols": 35, "rows": 6 });
  }

  function collapseFieldsContainer() {
    return $('<div>', { "class": "collapse", "id": "collapseReference", "aria-expanded": "true"});
  }
  
  var toggle = [ '<span class="collapse-toggle" >More <span class="glyphicon glyphicon-menu-down icon-link" aria-hidden="true"></span></span>',
		  '<span class="collapse-toggle" style="display: none;">Less <span class="glyphicon glyphicon-menu-up icon-link" aria-hidden="true"></span></span>'
		].join('');


  function collapse() {
    return wrapInFormGroup(
      $('<div>', { "class": 'col-sm-4 col-sm-offset-2' })
	.append(
	  $('<a>', { "data-toggle": 'collapse', "href": "#collapseReference",  "aria-expanded": "true", "aria-controls": "collapseReference",  "id": "toggle-reference-collapse"})
	    .append(toggle)
	)
    );

  }
  return NewReferenceForm;

}));
