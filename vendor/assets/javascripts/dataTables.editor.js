/*! DataTables Editor v1.4.2
 *
 * ©2012-2014 SpryMedia Ltd, all rights reserved.
 * License: editor.datatables.net/license
 */

/**
 * @summary     DataTables Editor
 * @description Table editing library for DataTables
 * @version     1.4.2
 * @file        dataTables.editor.js
 * @author      SpryMedia Ltd
 * @contact     www.datatables.net/contact
 */

/*jslint evil: true, undef: true, browser: true */
/*globals jQuery,alert,console */

(function( window, document, undefined ) {

var factory = function( $, DataTable ) {
"use strict";

if ( ! DataTable || ! DataTable.versionCheck || ! DataTable.versionCheck('1.10') ) {
	throw 'Editor requires DataTables 1.10 or newer';
}

/**
 * Editor is a plug-in for <a href="http://datatables.net">DataTables</a> which provides
 * an interface for creating, reading, editing and deleting and entries (a CRUD interface)
 * in a DataTable. The documentation presented here is primarily focused on presenting the
 * API for Editor. For a full list of features, examples and the server interface protocol,
 * please refer to the <a href="http://editor.datatables.net">Editor web-site</a>.
 *
 * Note that in this documentation, for brevity, the `DataTable` refers to the jQuery
 * parameter `jQuery.fn.dataTable` through which it may be  accessed. Therefore, when
 * creating a new Editor instance, use `jQuery.fn.Editor` as shown in the examples below.
 *
 *  @class
 *  @param {object} [oInit={}] Configuration object for Editor. Options
 *    are defined by {@link Editor.defaults}. The options which must be set
 *    are `ajaxUrl` and `domTable`.
 *  @requires jQuery 1.7+
 *  @requires DataTables 1.9+
 *  @requires TableTools 2.1+ - note that TableTools is only required if you want to use
 *    the row selection and button controls TableTools provides, but is not mandatory
 *    for Editor. If used, the TableTools should be loaded before Editor.
 *
 *  @example
 *    // Basic initialisation - this example shows a table with 2 columns, each of which is editable
 *    // as a text input and provides add, edit and delete buttons by making use of TableTools
 *    // (Editor provides three buttons that extend the abilities of TableTools).
 *    $(document).ready(function() {
 *      var editor = new $.fn.Editor( {
 *        "ajaxUrl": "php/index.php",
 *        "domTable": "#example",
 *        "fields": [ {
 *            "label": "Browser:",
 *            "name": "browser"
 *          }, {
 *            "label": "Rendering engine:",
 *            "name": "engine"
 *          }, {
 *            "label": "Platform:",
 *            "name": "platform"
 *          }, {
 *            "label": "Version:",
 *            "name": "version"
 *          }, {
 *            "label": "CSS grade:",
 *            "name": "grade"
 *          }
 *        ]
 *      } );
 *
 *      $('#example').dataTable( {
 *        "sDom": "Tfrtip",
 *        "sAjaxSource": "php/index.php",
 *        "aoColumns": [
 *          { "mData": "browser" },
 *          { "mData": "engine" },
 *          { "mData": "platform" },
 *          { "mData": "version", "sClass": "center" },
 *          { "mData": "grade", "sClass": "center" }
 *        ],
 *        "oTableTools": {
 *          "sRowSelect": "multi",
 *          "aButtons": [
 *            { "sExtends": "dte_create", "dte": editor },
 *            { "sExtends": "dte_edit",   "dte": editor },
 *            { "sExtends": "dte_remove", "dte": editor }
 *          ]
 *        }
 *      } );
 *    } );
 */
var Editor = function ( opts )
{
	if ( ! this instanceof Editor ) {
		alert( "DataTables Editor must be initialised as a 'new' instance'" );
	}

	this._constructor( opts );
};

// Export Editor as a DataTables property
DataTable.Editor = Editor;
$.fn.DataTable.Editor = Editor;

// Internal methods


/**
 * Get an Editor node based on the data-dte-e (element) attribute and return it
 * as a jQuery object.
 *  @param {string} dis The data-dte-e attribute name to match for the element
 *  @param {node} [ctx=document] The context for the search - recommended this
 *    parameter is included for performance.
 *  @returns {jQuery} jQuery object of found node(s).
 *  @private
 */
var _editor_el = function ( dis, ctx )
{
	if ( ctx === undefined ) {
		ctx = document;
	}

	return $('*[data-dte-e="'+dis+'"]', ctx);
};


/** @internal Counter for unique event namespaces in the inline control */
var __inlineCounter = 0;


// Field class


Editor.Field = function ( opts, classes, host ) {
	var that = this;

	opts = $.extend( true, {}, Editor.Field.defaults, opts );
	this.s = $.extend( {}, Editor.Field.settings, { // has to be a shallow copy!
		type:    Editor.fieldTypes[ opts.type ],
		name:    opts.name,
		classes: classes,
		host:    host,
		opts:    opts
	} );

	// No id, so assign one to have the label reference work
	if ( ! opts.id ) {
		opts.id = 'DTE_Field_'+opts.name;
	}

	// Backwards compatibility
	if ( opts.dataProp ) {
		opts.data = opts.dataProp;
	}

	// If no `data` option is given, then we use the name from the field as the
	// data prop to read data for the field from DataTables
	if ( opts.data === '' ) {
		opts.data = opts.name;
	}

	// Get and set functions in the data object for the record
	var dtPrivateApi = DataTable.ext.oApi;
	this.valFromData = function ( d ) { // get val from data
		// wrapper to automatically pass `editor` as the type
		return dtPrivateApi._fnGetObjectDataFn( opts.data )( d, 'editor' );
	};
	this.valToData = dtPrivateApi._fnSetObjectDataFn( opts.data ); // set val to data

	// Field HTML structure
	var template = $(
		'<div class="'+classes.wrapper+' '+classes.typePrefix+opts.type+' '+classes.namePrefix+opts.name+' '+opts.className+'">'+
			'<label data-dte-e="label" class="'+classes.label+'" for="'+opts.id+'">'+
				opts.label+
				'<div data-dte-e="msg-label" class="'+classes['msg-label']+'">'+opts.labelInfo+'</div>'+
			'</label>'+
			'<div data-dte-e="input" class="'+classes.input+'">'+
				// Field specific HTML is added here if there is any
				'<div data-dte-e="msg-error" class="'+classes['msg-error']+'"></div>'+
				'<div data-dte-e="msg-message" class="'+classes['msg-message']+'"></div>'+
				'<div data-dte-e="msg-info" class="'+classes['msg-info']+'">'+opts.fieldInfo+'</div>'+
			'</div>'+
		'</div>');

	var input = this._typeFn( 'create', opts );
	if ( input !== null ) {
		_editor_el('input', template).prepend( input );
	}
	else {
		template.css('display', "none");
	}

	this.dom = $.extend( true, {}, Editor.Field.models.dom, {
		container:    template,
		label:        _editor_el('label', template),
		fieldInfo:    _editor_el('msg-info', template),
		labelInfo:    _editor_el('msg-label', template),
		fieldError:   _editor_el('msg-error', template),
		fieldMessage: _editor_el('msg-message', template)
	} );


	// Field type extension methods - add a method to the field for the public
	// methods that each field type defines beyond the default ones that already
	// exist as part of this instance
	$.each( this.s.type, function ( name, fn ) {
		if ( typeof fn === 'function' && that[name] === undefined ) {
			that[ name ] = function () {
				var args = Array.prototype.slice.call( arguments );

				args.unshift( name );
				var ret = that._typeFn.apply( that, args );

				// Return the given value if there is one, or the field instance
				// for chaining if there is no value
				return ret === undefined ?
					that :
					ret;
			};
		}
	} );
};


Editor.Field.prototype = {
	dataSrc: function () {
		return this.s.opts.data;
	},

	valFromData: null,

	valToData: null,

	destroy: function () {
		// remove el
		this.dom.container.remove();

		// field's own destroy method if there is one
		this._typeFn( 'destroy' );
		return this;
	},

	def: function ( set ) {
		var opts = this.s.opts;

		if ( set === undefined ) {
			// Backwards compat
			var def = opts['default'] !== undefined ?
				opts['default'] :
				opts.def;

			return $.isFunction( def ) ?
				def() :
				def;
		}

		opts.def = set;
		return this;
	},

	disable: function () {
		this._typeFn( 'disable' );
		return this;
	},

	displayed: function () {
		var container = this.dom.container;

		return container.parents('body').length && container.css('display') != 'none' ?
			true :
			false;
	},

	enable: function () {
		this._typeFn( 'enable' );
		return this;
	},

	error: function ( msg, fn ) {
		var classes = this.s.classes;

		// Add or remove the error class
		if ( msg ) {
			this.dom.container.addClass( classes.error );
		}
		else {
			this.dom.container.removeClass( classes.error );
		}

		return this._msg( this.dom.fieldError, msg, fn );
	},

	inError: function () {
		return this.dom.container.hasClass( this.s.classes.error );
	},

	input: function () {
		return this.s.type.input ?
			this._typeFn( 'input' ) :
			$('input, select, textarea', this.dom.container);
	},

	focus: function () {
		if ( this.s.type.focus ) {
			this._typeFn( 'focus' );
		}
		else {
			$('input, select, textarea', this.dom.container).focus();
		}

		return this;
	},

	get: function () {
		var val = this._typeFn( 'get' );
		return val !== undefined ?
			val :
			this.def();
	},

	hide: function ( animate ) {
		var el = this.dom.container;

		if ( animate === undefined ) {
			animate = true;
		}

		if ( this.s.host.display() && animate ) {
			el.slideUp();
		}
		else {
			el.css( 'display', 'none' );
		}
		return this;
	},

	label: function ( str ) {
		var label = this.dom.label;

		if ( str === undefined ) {
			return label.html();
		}

		label.html( str );
		return this;
	},

	message: function ( msg, fn ) {
		return this._msg( this.dom.fieldMessage, msg, fn );
	},

	name: function () {
		return this.s.opts.name;
	},

	node: function () {
		return this.dom.container[0];
	},

	set: function ( val ) {
		return this._typeFn( 'set', val );
	},

	show: function ( animate ) {
		var el = this.dom.container;

		if ( animate === undefined ) {
			animate = true;
		}

		if ( this.s.host.display() && animate ) {
			el.slideDown();
		}
		else {
			el.css( 'display', 'block' );
		}
		return this;
	},

	val: function ( val ) {
		return val === undefined ?
			this.get() :
			this.set( val );
	},

	_errorNode: function () {
		return this.dom.fieldError;
	},



	_msg: function ( el, msg, fn ) {
		if ( el.parent().is(":visible") ) {
			el.html( msg );

			if ( msg ) {
				el.slideDown( fn ); // fn can be undefined - so jQuery won't execute it
			}
			else {
				el.slideUp( fn );
			}
		}
		else {
			// Not visible, so immediately set, or blank out the element
			el
				.html( msg || '' )
				.css( 'display', msg ? 'block' : 'none' );

			if ( fn ) {
				fn();
			}
		}

		return this;
	},


	_typeFn: function ( name /*, ... */ ) {
		// Remove the name from the arguments list, so the rest can be passed
		// straight into the field type
		var args = Array.prototype.slice.call( arguments );
		args.shift();

		// Insert the options as the first parameter - all field type methods
		// take the field's configuration object as the first parameter
		args.unshift( this.s.opts );

		var fn = this.s.type[ name ];
		if ( fn ) {
			return fn.apply( this.s.host, args );
		}
	}
};


Editor.Field.models = {};


/**
 * Initialisation options that can be given to Editor.Field at initialisation
 * time.
 *  @namespace
 */
Editor.Field.defaults = {
	/**
	 * Class name to assign to the field's container element (in addition to the other
	 * classes that Editor assigns by default).
	 *  @type string
	 *  @default <i>Empty string</i>
	 */
	"className": "",

	/**
	 * The data property (`mData` in DataTables terminology) that is used to
	 * read from and write to the table. If not given then it will take the same
	 * value as the `name` that is given in the field object. Note that `data`
	 * can be given as null, which will result in Editor not using a DataTables
	 * row property for the value of the field for either getting or setting
	 * data.
	 *
	 * In previous versions of Editor (1.2-) this was called `dataProp`. The old
	 * name can still be used for backwards compatibility, but the new form is
	 * preferred.
	 *  @type string
	 *  @default <i>Empty string</i>
	 */
	"data": "",

	/**
	 * The default value for the field. Used when creating new rows (editing will
	 * use the currently set value). If given as a function the function will be
	 * executed and the returned value used as the default
	 *
	 * In Editor 1.2 and earlier this field was called `default` - however
	 * `default` is a reserved word in Javascript, so it couldn't be used
	 * unquoted. `default` will still work with Editor 1.3, but the new property
	 * name of `def` is preferred.
	 *  @type string|function
	 *  @default <i>Empty string</i>
	 */
	"def": "",

	/**
	 * Helpful information text about the field that is shown below the input control.
	 *  @type string
	 *  @default <i>Empty string</i>
	 */
	"fieldInfo": "",

	/**
	 * The ID of the field. This is used by the `label` HTML tag as the "for" attribute 
	 * improved accessibility. Although this using this parameter is not mandatory,
	 * it is a good idea to assign the ID to the DOM element that is the input for the
	 * field (if this is applicable).
	 *  @type string
	 *  @default <i>Calculated</i>
	 */
	"id": "",

	/**
	 * The label to display for the field input (i.e. the name that is visually 
	 * assigned to the field).
	 *  @type string
	 *  @default <i>Empty string</i>
	 */
	"label": "",

	/**
	 * Helpful information text about the field that is shown below the field label.
	 *  @type string
	 *  @default <i>Empty string</i>
	 */
	"labelInfo": "",

	/**
	 * The name for the field that is submitted to the server. This is the only
	 * mandatory parameter in the field description object.
	 *  @type string
	 *  @default <i>null</i>
	 */
	"name": null,

	/**
	 * The input control that is presented to the end user. The options available 
	 * are defined by {@link Editor.fieldTypes} and any extensions made 
	 * to that object.
	 *  @type string
	 *  @default text
	 */
	"type": "text"
};



/**
 * 
 *  @namespace
 */
Editor.Field.models.settings = {
	type: null,
	name: null,
	classes: null,
	opts: null,
	host: null
};



/**
 * 
 *  @namespace
 */
Editor.Field.models.dom = {
	container: null,
	label: null,
	labelInfo: null,
	fieldInfo: null,
	fieldError: null,
	fieldMessage: null
};


/*
 * Models
 */

/**
 * Object models container, for the various models that DataTables has available
 * to it. These models define the objects that are used to hold the active state
 * and configuration of the table.
 *  @namespace
 */
Editor.models = {};


/**
 * Editor makes very few assumptions about how its form will actually be
 * displayed to the end user (where in the DOM, interaction etc), instead
 * focusing on providing form interaction controls only. To actually display
 * a form in the browser we need to use a display controller, and then select
 * which one we want to use at initialisation time using the `display`
 * option. For example a display controller could display the form in a
 * lightbox (as the default display controller does), it could completely
 * empty the document and put only the form in place, ir could work with
 * DataTables to use `fnOpen` / `fnClose` to show the form in a "details" row
 * and so on.
 *
 * Editor has two built-in display controllers ('lightbox' and 'envelope'),
 * but others can readily be created and installed for use as plug-ins. When
 * creating a display controller plug-in you **must** implement the methods
 * in this control. Additionally when closing the display internally you
 * **must** trigger a `requestClose` event which Editor will listen
 * for and act upon (this allows Editor to ask the user if they are sure
 * they want to close the form, for example).
 *  @namespace
 */
Editor.models.displayController = {
	/**
	 * Initialisation method, called by Editor when itself, initialises.
	 *  @param {object} dte The DataTables Editor instance that has requested
	 *    the action - this allows access to the Editor API if required.
	 *  @returns {object} The object that Editor will use to run the 'open'
	 *    and 'close' methods against. If static methods are used then
	 *    just return the object that holds the init, open and close methods,
	 *    however, this allows the display to be created with a 'new'
	 *    instance of an object is the display controller calls for that.
	 *  @type function
	 */
	"init": function ( dte ) {},

	/**
	 * Display the form (add it to the visual display in the document)
	 *  @param {object} dte The DataTables Editor instance that has requested
	 *    the action - this allows access to the Editor API if required.
	 *  @param {element} append The DOM node that contains the form to be
	 *    displayed
	 *  @param {function} [fn] Callback function that is to be executed when
	 *    the form has been displayed. Note that this parameter is optional.
	 */
	"open": function ( dte, append, fn ) {},

	/**
	 * Hide the form (remove it form the visual display in the document)
	 *  @param {object} dte The DataTables Editor instance that has requested
	 *    the action - this allows access to the Editor API if required.
	 *  @param {function} [fn] Callback function that is to be executed when
	 *    the form has been hidden. Note that this parameter is optional.
	 */
	"close": function ( dte, fn ) {}
};



/**
 * Model object for input types which are available to fields (assigned to
 * {@link Editor.fieldTypes}). Any plug-ins which add additional
 * input types to Editor **must** implement the methods in this object 
 * (dummy functions are given in the model so they can be used as defaults
 * if extending this object).
 *
 * All functions in the model are executed in the Editor's instance scope,
 * so you have full access to the settings object and the API methods if
 * required.
 *  @namespace
 *  @example
 *    // Add a simple text input (the 'text' type that is built into Editor
 *    // does this, so you wouldn't implement this exactly as show, but it
 *    // it is a good example.
 *
 *    var Editor = $.fn.Editor;
 *
 *    Editor.fieldTypes.myInput = $.extend( true, {}, Editor.models.type, {
 *      "create": function ( conf ) {
 *        // We store the 'input' element in the configuration object so
 *        // we can easily access it again in future.
 *        conf._input = document.createElement('input');
 *        conf._input.id = conf.id;
 *        return conf._input;
 *      },
 *    
 *      "get": function ( conf ) {
 *        return conf._input.value;
 *      },
 *    
 *      "set": function ( conf, val ) {
 *        conf._input.value = val;
 *      },
 *    
 *      "enable": function ( conf ) {
 *        conf._input.disabled = false;
 *      },
 *    
 *      "disable": function ( conf ) {
 *        conf._input.disabled = true;
 *      }
 *    } );
 */
Editor.models.fieldType = {
	/**
	 * Create the field - this is called when the field is added to the form.
	 * Note that this is called at initialisation time, or when the 
	 * {@link Editor#add} API method is called, not when the form is displayed. 
	 * If you need to know when the form is shown, you can use the API to listen 
	 * for the `open` event.
	 *  @param {object} conf The configuration object for the field in question:
	 *    {@link Editor.models.field}.
	 *  @returns {element|null} The input element (or a wrapping element if a more
	 *    complex input is required) or null if nothing is to be added to the
	 *    DOM for this input type.
	 *  @type function
	 */
	"create": function ( conf ) {},

	/**
	 * Get the value from the field
	 *  @param {object} conf The configuration object for the field in question:
	 *    {@link Editor.models.field}.
	 *  @returns {*} The value from the field - the exact value will depend on the
	 *    formatting required by the input type control.
	 *  @type function
	 */
	"get": function ( conf ) {},

	/**
	 * Set the value for a field
	 *  @param {object} conf The configuration object for the field in question:
	 *    {@link Editor.models.field}.
	 *  @param {*} val The value to set the field to - the exact value will
	 *    depend on the formatting required by the input type control.
	 *  @type function
	 */
	"set": function ( conf, val ) {},

	/**
	 * Enable the field - i.e. allow user interface
	 *  @param {object} conf The configuration object for the field in question:
	 *    {@link Editor.models.field}.
	 *  @type function
	 */
	"enable": function ( conf ) {},

	/**
	 * Disable the field - i.e. disallow user interface
	 *  @param {object} conf The configuration object for the field in question:
	 *    {@link Editor.models.field}.
	 *  @type function
	 */
	"disable": function ( conf ) {}
};



/**
 * Settings object for Editor - this provides the state for each instance of
 * Editor and can be accessed through the instance's `s` property. Note that the
 * settings object is considered to be "private" and thus is liable to change
 * between versions. As such if you do read any of the setting parameters,
 * please keep this in mind when upgrading!
 *  @namespace
 */
Editor.models.settings = {
	/**
	 * URL to submit Ajax data to.
	 * This is directly set by the initialisation parameter / default of the same name.
	 *  @type string
	 *  @default null
	 */
	"ajaxUrl": null,

	/**
	 * Ajax submit function.
	 * This is directly set by the initialisation parameter / default of the same name.
	 *  @type function
	 *  @default null
	 */
	"ajax": null,

	/**
	 * Data source for get and set data actions. This allows Editor to perform
	 * as an Editor for virtually any data source simply by defining additional
	 * data sources.
	 *  @type object
	 *  @default null
	 */
	"dataSource": null,

	/**
	 * DataTable selector, can be anything that the Api supports
	 * This is directly set by the initialisation parameter / default of the same name.
	 *  @type string
	 *  @default null
	 */
	"domTable": null,

	/**
	 * The initialisation object that was given by the user - stored for future reference.
	 * This is directly set by the initialisation parameter / default of the same name.
	 *  @type string
	 *  @default null
	 */
	"opts": null,

	/**
	 * The display controller object for the Form.
	 * This is directly set by the initialisation parameter / default of the same name.
	 *  @type string
	 *  @default null
	 */
	"displayController": null,

	/**
	 * The form fields - see {@link Editor.models.field} for details of the 
	 * objects held in this array.
	 *  @type object
	 *  @default null
	 */
	"fields": {},

	/**
	 * Field order - order that the fields will appear in on the form. Array of strings,
	 * the names of the fields.
	 *  @type array
	 *  @default null
	 */
	"order": [],

	/**
	 * The ID of the row being edited (set to -1 on create and remove actions)
	 *  @type string
	 *  @default null
	 */
	"id": -1,

	/**
	 * Flag to indicate if the form is currently displayed (true) or not (false)
	 *  @type string
	 *  @default null
	 */
	"displayed": false,

	/**
	 * Flag to indicate if the form is current in a processing state (true) or not (false)
	 *  @type string
	 *  @default null
	 */
	"processing": false,

	/**
	 * Developer provided identifier for the elements to be edited (i.e. at
	 * `dt-type row-selector` to select rows to edit or delete.
	 *  @type array
	 *  @default null
	 */
	"modifier": null,

	/**
	 * The current form action - 'create', 'edit' or 'remove'. If no current action then
	 * it is set to null.
	 *  @type string
	 *  @default null
	 */
	"action": null,

	/**
	 * JSON property from which to read / write the row's ID property.
	 *  @type string
	 *  @default null
	 */
	"idSrc": null
};



/**
 * Model of the buttons that can be used with the {@link Editor#buttons}
 * method for creating and displaying buttons (also the {@link Editor#button}
 * argument option for the {@link Editor#create}, {@link Editor#edit} and 
 * {@link Editor#remove} methods). Although you don't need to extend this object,
 * it is available for reference to show the options available.
 *  @namespace
 */
Editor.models.button = {
	/**
	 * The text to put into the button. This can be any HTML string you wish as 
	 * it will be rendered as HTML (allowing images etc to be shown inside the
	 * button).
	 *  @type string
	 *  @default null
	 */
	"label": null,

	/**
	 * Callback function which the button is activated. For example for a 'submit' 
	 * button you would call the {@link Editor#submit} API method, while for a cancel button
	 * you would call the {@link Editor#close} API method. Note that the function is executed 
	 * in the scope of the Editor instance, so you can call the Editor's API methods 
	 * using the `this` keyword.
	 *  @type function
	 *  @default null
	 */
	"fn": null,

	/**
	 * The CSS class(es) to apply to the button which can be useful for styling buttons 
	 * which preform different functions each with a distinctive visual appearance.
	 *  @type string
	 *  @default null
	 */
	"className": null
};



/**
 * This is really an internal namespace
 *
 *  @namespace
 */
Editor.models.formOptions = {
	/**
	 *
	 *  @type boolean
	 *  @default null
	 */
	"submitOnReturn": true,

	/**
	 *
	 *  @type boolean
	 *  @default null
	 */
	"submitOnBlur": false,

	/**
	 *
	 *  @type boolean
	 *  @default null
	 */
	"blurOnBackground": true,

	/**
	 *
	 *  @type boolean
	 *  @default null
	 */
	"closeOnComplete": true,

	/**
	 *
	 *  @type string
	 *  @default "close"
	 */
	"onEsc": "close",

	/**
	 *
	 *  @type null|integer|string
	 *  @default 0
	 */
	"focus": 0,

	/**
	 *
	 *  @type string|boolean|array|object
	 *  @default null
	 */
	"buttons": true,

	/**
	 *
	 *  @type string|boolean
	 *  @default null
	 */
	"title": true,

	/**
	 *
	 *  @type string|boolean
	 *  @default null
	 */
	"message": true
};


/*
 * Display controllers
 */

/**
 * Display controllers. See {@link Editor.models.displayController} for
 * full information about the display controller options for Editor. The display
 * controllers given in this object can be utilised by specifying the
 * {@link Editor.defaults.display} option.
 *  @namespace
 */
Editor.display = {};


(function(window, document, $, DataTable) {


var self;

Editor.display.lightbox = $.extend( true, {}, Editor.models.displayController, {
	/*
	 * API methods
	 */
	"init": function ( dte ) {
		self._init();
		return self;
	},

	"open": function ( dte, append, callback ) {
		if ( self._shown ) {
			if ( callback ) {
				callback();
			}
			return;
		}

		self._dte = dte;

		var content = self._dom.content;
		content.children().detach();
		content
			.append( append )
			.append( self._dom.close );

		self._shown = true;
		self._show( callback );
	},

	"close": function ( dte, callback ) {
		if ( !self._shown ) {
			if ( callback ) {
				callback();
			}
			return;
		}

		self._dte = dte;
		self._hide( callback );

		self._shown = false;
	},


	/*
	 * Private methods
	 */
	"_init": function () {
		if ( self._ready ) {
			return;
		}

		var dom = self._dom;
		dom.content = $('div.DTED_Lightbox_Content', self._dom.wrapper);

		dom.wrapper.css( 'opacity', 0 );
		dom.background.css( 'opacity', 0 );
	},


	"_show": function ( callback ) {
		var that = this;
		var dom = self._dom;

		// Mobiles have very poor position fixed abilities, so we need to know
		// when using mobile A media query isn't good enough
		if ( window.orientation !== undefined ) {
			$('body').addClass( 'DTED_Lightbox_Mobile' );
		}

		// Adjust size for the content
		dom.content.css( 'height', 'auto' );
		dom.wrapper.css( {
			top: -self.conf.offsetAni
		} );

		$('body')
			.append( self._dom.background )
			.append( self._dom.wrapper );

		self._heightCalc();

		dom.wrapper.animate( {
			opacity: 1,
			top: 0
		}, callback );

		dom.background.animate( {
			opacity: 1
		} );

		// Event handlers - assign on show (and unbind on hide) rather than init
		// since we might need to refer to different editor instances - 12563
		dom.close.bind( 'click.DTED_Lightbox', function (e) {
			self._dte.close();
		} );

		dom.background.bind( 'click.DTED_Lightbox', function (e) {
			self._dte.blur();
		} );

		$('div.DTED_Lightbox_Content_Wrapper', dom.wrapper).bind( 'click.DTED_Lightbox', function (e) {
			if ( $(e.target).hasClass('DTED_Lightbox_Content_Wrapper') ) {
				self._dte.blur();
			}
		} );

		$(window).bind( 'resize.DTED_Lightbox', function () {
			self._heightCalc();
		} );

		self._scrollTop = $('body').scrollTop();

		// For smaller screens we need to hide the other elements in the
		// document since iOS and Android both mess up display:fixed when
		// the virtual keyboard is shown
		if ( window.orientation !== undefined ) {
			var kids = $('body').children().not( dom.background ).not( dom.wrapper );
			$('body').append( '<div class="DTED_Lightbox_Shown"/>' );
			$('div.DTED_Lightbox_Shown').append( kids );
		}
	},


	"_heightCalc": function () {
		// Set the max-height for the form content
		var dom = self._dom;
		var maxHeight = $(window).height() - (self.conf.windowPadding*2) -
			$('div.DTE_Header', dom.wrapper).outerHeight() -
			$('div.DTE_Footer', dom.wrapper).outerHeight();

		$('div.DTE_Body_Content', dom.wrapper).css(
			'maxHeight',
			maxHeight
		);
	},


	"_hide": function ( callback ) {
		var dom = self._dom;

		if ( !callback ) {
			callback = function () {};
		}

		if ( window.orientation !== undefined  ) {
			var show = $('div.DTED_Lightbox_Shown');
			show.children().appendTo('body');
			show.remove();
		}

		// Restore scroll state
		$('body')
			.removeClass( 'DTED_Lightbox_Mobile' )
			.scrollTop( self._scrollTop );

		dom.wrapper.animate( {
			opacity: 0,
			top: self.conf.offsetAni
		}, function () {
			$(this).detach();
			callback();
		} );

		dom.background.animate( {
			opacity: 0
		}, function () {
			$(this).detach();
		} );

		// Event handlers
		dom.close.unbind( 'click.DTED_Lightbox' );
		dom.background.unbind( 'click.DTED_Lightbox' );
		$('div.DTED_Lightbox_Content_Wrapper', dom.wrapper).unbind( 'click.DTED_Lightbox' );
		$(window).unbind( 'resize.DTED_Lightbox' );
	},


	/*
	 * Private properties
	 */
	"_dte": null,
	"_ready": false,
	"_shown": false,
	"_dom": {
		"wrapper": $(
			'<div class="DTED DTED_Lightbox_Wrapper">'+
				'<div class="DTED_Lightbox_Container">'+
					'<div class="DTED_Lightbox_Content_Wrapper">'+
						'<div class="DTED_Lightbox_Content">'+
						'</div>'+
					'</div>'+
				'</div>'+
			'</div>'
		),

		"background": $(
			'<div class="DTED_Lightbox_Background"><div/></div>'
		),

		"close": $(
			'<div class="DTED_Lightbox_Close"></div>'
		),

		"content": null
	}
} );

self = Editor.display.lightbox;

self.conf = {
	"offsetAni": 25,
	"windowPadding": 25
};


}(window, document, jQuery, jQuery.fn.dataTable));



(function(window, document, $, DataTable) {


var self;

Editor.display.envelope = $.extend( true, {}, Editor.models.displayController, {
	/*
	 * API methods
	 */
	"init": function ( dte ) {
		self._dte = dte;
		self._init();
		return self;
	},


	"open": function ( dte, append, callback ) {
		self._dte = dte;
		$(self._dom.content).children().detach();
		self._dom.content.appendChild( append );
		self._dom.content.appendChild( self._dom.close );

		self._show( callback );
	},


	"close": function ( dte, callback ) {
		self._dte = dte;
		self._hide( callback );
	},


	/*
	 * Private methods
	 */
	"_init": function () {
		if ( self._ready ) {
			return;
		}

		self._dom.content = $('div.DTED_Envelope_Container', self._dom.wrapper)[0];

		document.body.appendChild( self._dom.background );
		document.body.appendChild( self._dom.wrapper );

		// For IE6-8 we need to make it a block element to read the opacity...
		self._dom.background.style.visbility = 'hidden';
		self._dom.background.style.display = 'block';
		self._cssBackgroundOpacity = $(self._dom.background).css('opacity');
		self._dom.background.style.display = 'none';
		self._dom.background.style.visbility = 'visible';
	},


	"_show": function ( callback ) {
		var that = this;
		var formHeight;

		if ( !callback ) {
			callback = function () {};
		}

		// Adjust size for the content
		self._dom.content.style.height = 'auto';

		var style = self._dom.wrapper.style;
		style.opacity = 0;
		style.display = 'block';

		var targetRow = self._findAttachRow();
		var height = self._heightCalc();
		var width = targetRow.offsetWidth;

		style.display = 'none';
		style.opacity = 1;

		// Prep the display
		self._dom.wrapper.style.width = width+"px";
		self._dom.wrapper.style.marginLeft = -(width/2)+"px";
		self._dom.wrapper.style.top = ($(targetRow).offset().top + targetRow.offsetHeight)+"px";
		self._dom.content.style.top = ((-1 * height) - 20)+"px";

		// Start animating in the background
		self._dom.background.style.opacity = 0;
		self._dom.background.style.display = 'block';
		$(self._dom.background).animate( {
			'opacity': self._cssBackgroundOpacity
		}, 'normal' );

		// Animate in the display
		$(self._dom.wrapper).fadeIn();

		// Slide the slider down to 'open' the view
		if ( self.conf.windowScroll ) {
			// Scroll the window so we can see the editor first
			$('html,body').animate( {
				"scrollTop": $(targetRow).offset().top + targetRow.offsetHeight - self.conf.windowPadding
			}, function () {
				// Now open the editor
				$(self._dom.content).animate( {
					"top": 0
				}, 600, callback );
			} );
		}
		else {
			// Just open the editor without moving the document position
			$(self._dom.content).animate( {
				"top": 0
			}, 600, callback );
		}

		// Event handlers
		$(self._dom.close).bind( 'click.DTED_Envelope', function (e) {
			self._dte.close();
		} );

		$(self._dom.background).bind( 'click.DTED_Envelope', function (e) {
			self._dte.blur();
		} );

		$('div.DTED_Lightbox_Content_Wrapper', self._dom.wrapper).bind( 'click.DTED_Envelope', function (e) {
			if ( $(e.target).hasClass('DTED_Envelope_Content_Wrapper') ) {
				self._dte.blur();
			}
		} );

		$(window).bind( 'resize.DTED_Envelope', function () {
			self._heightCalc();
		} );
	},


	"_heightCalc": function () {
		var formHeight;

		formHeight = self.conf.heightCalc ?
			self.conf.heightCalc( self._dom.wrapper ) :
			$(self._dom.content).children().height();

		// Set the max-height for the form content
		var maxHeight = $(window).height() - (self.conf.windowPadding*2) -
			$('div.DTE_Header', self._dom.wrapper).outerHeight() -
			$('div.DTE_Footer', self._dom.wrapper).outerHeight();

		$('div.DTE_Body_Content', self._dom.wrapper).css('maxHeight', maxHeight);

		return $(self._dte.dom.wrapper).outerHeight();
	},


	"_hide": function ( callback ) {
		if ( !callback ) {
			callback = function () {};
		}

		$(self._dom.content).animate( {
			"top": -(self._dom.content.offsetHeight+50)
		}, 600, function () {
			$([self._dom.wrapper, self._dom.background]).fadeOut( 'normal', callback );
		} );

		// Event handlers
		$(self._dom.close).unbind( 'click.DTED_Lightbox' );
		$(self._dom.background).unbind( 'click.DTED_Lightbox' );
		$('div.DTED_Lightbox_Content_Wrapper', self._dom.wrapper).unbind( 'click.DTED_Lightbox' );
		$(window).unbind( 'resize.DTED_Lightbox' );
	},


	"_findAttachRow": function () {
		var dt = $(self._dte.s.table).DataTable();

		// Figure out where we want to put the form display
		if ( self.conf.attach === 'head' ) {
			return dt.table().header();
		}
		else if ( self._dte.s.action === 'create' ) {
			return dt.table().header();
		}
		else {
			return dt.row( self._dte.s.modifier ).node();
		}
	},


	/*
	 * Private properties
	 */
	"_dte": null,
	"_ready": false,
	"_cssBackgroundOpacity": 1, // read from the CSS dynamically, but stored for future reference


	"_dom": {
		"wrapper": $(
			'<div class="DTED DTED_Envelope_Wrapper">'+
				'<div class="DTED_Envelope_ShadowLeft"></div>'+
				'<div class="DTED_Envelope_ShadowRight"></div>'+
				'<div class="DTED_Envelope_Container"></div>'+
			'</div>'
		)[0],

		"background": $(
			'<div class="DTED_Envelope_Background"><div/></div>'
		)[0],

		"close": $(
			'<div class="DTED_Envelope_Close">&times;</div>'
		)[0],

		"content": null
	}
} );


// Assign to 'self' for easy referencing of our own object!
self = Editor.display.envelope;


// Configuration object - can be accessed globally using 
// $.fn.Editor.display.envelope.conf (!)
self.conf = {
	"windowPadding": 50,
	"heightCalc": null,
	"attach": "row",
	"windowScroll": true
};


}(window, document, jQuery, jQuery.fn.dataTable));


/*
 * Prototype includes
 */


/**
 * Add a new field to the from. This is the method that is called automatically when
 * fields are given in the initialisation objects as {@link Editor.defaults.fields}.
 *  @memberOf Editor
 *  @param {object|array} field The object that describes the field (the full object is
 *    described by {@link Editor.model.field}. Note that multiple fields can
 *    be given by passing in an array of field definitions.
 */
Editor.prototype.add = function ( cfg )
{
	// Allow multiple fields to be added at the same time
	if ( $.isArray( cfg ) ) {
		for ( var i=0, iLen=cfg.length ; i<iLen ; i++ ) {
			this.add( cfg[i] );
		}
	}
	else {
		var name = cfg.name;

		if ( name === undefined ) {
			throw "Error adding field. The field requires a `name` option";
		}

		if ( this.s.fields[ name ] ) {
			throw "Error adding field '"+name+"'. A field already exists with this name";
		}

		// Allow the data source to add / modify the field properties
		// Dev: would this be better as an event `preAddField`? And have the
		// data sources init only once, but can listen for such events? More
		// complexity, but probably more flexible...
		this._dataSource( 'initField', cfg );

		this.s.fields[ name ] = new Editor.Field( cfg, this.classes.field, this );
		this.s.order.push( name );
	}

	return this;
};


/**
 * Blur the currently displayed editor.
 *
 * A blur is different from a `close()` in that it might cause either a close or
 * the form to be submitted. A typical example of a blur would be clicking on
 * the background of the bubble or main editing forms - i.e. it might be a
 * close, or it might submit depending upon the configuration, while a click on
 * the close box is a very definite close.
 *
 * @return {Editor} Editor instance, for chaining
 */
Editor.prototype.blur = function ()
{
	this._blur();

	return this;
};



Editor.prototype.bubble = function ( cells, fieldNames, opts )
{
	var that = this;
	var fields, nodes, ind, edit;

	// Some other field in inline edit mode?
	if ( this._tidy( function () { that.bubble( cells, fieldNames, opts ); } ) ) {
		return this;
	}

	// Argument shifting
	if ( $.isPlainObject( fieldNames ) ) {
		opts = fieldNames;
		fieldNames = undefined;
	}

	opts = $.extend( {}, this.s.formOptions.bubble, opts );

	// Get the node, edit id and field from the data source
	if ( fieldNames ) {
		if ( ! $.isArray( fieldNames ) ) {
			fieldNames = [ fieldNames ];
		}

		if ( ! $.isArray( cells ) ) {
			cells = [ cells ];
		}

		fields = $.map( fieldNames, function ( name, i ) {
			return that.s.fields[ name ];
		} );

		ind = $.map( cells, function ( cell, i ) {
			return that._dataSource( 'individual', cells );
		} );
	}
	else {
		if ( ! $.isArray( cells ) ) {
			cells = [ cells ];
		}

		ind = $.map( cells, function ( cell, i ) {
			return that._dataSource( 'individual', cell, null, that.s.fields );
		} );

		fields = $.map( ind, function ( i ) {
			return i.field;
		} );
	}

	this.s.bubbleNodes = $.map( ind, function ( i ) {
		return i.node;
	} );

	edit = $.map( ind, function ( i ) {
		return i.edit;
	} ).sort();

	if ( edit[0] !== edit[ edit.length-1 ] ) {
		throw 'Editing is limited to a single row only';
	}

	this._edit( edit[0], 'bubble' );
	var namespace = this._formOptions( opts );

	// Keep the bubble in position on resize
	$(window).on( 'resize.'+namespace, function () {
		that.bubblePosition();
	} );

	var ret = this._preopen( 'bubble' );
	if ( ! ret ) {
		return this;
	}

	// Create container display
	var classes = this.classes.bubble;
	var container = $(
			'<div class="'+classes.wrapper+'">'+
				'<div class="'+classes.liner+'">'+
					'<div class="'+classes.table+'">'+
						'<div class="'+classes.close+'" />'+
					'</div>'+
				'</div>'+
				'<div class="'+classes.pointer+'" />'+
			'</div>'
		)
		.appendTo( 'body' );

	var background = $( '<div class="'+classes.bg+'"><div/></div>' )
		.appendTo( 'body' );

	// Add fields to the container
	this._displayReorder( fields );

	var liner = container.children().eq(0);
	var table = liner.children();
	var close = table.children();
	liner.append( this.dom.formError );
	table.prepend( this.dom.form );

	if ( opts.message ) {
		liner.prepend( this.dom.formInfo );
	}

	if ( opts.title ) {
		liner.prepend( this.dom.header );
	}

	if ( opts.buttons ) {
		table.append( this.dom.buttons );
	}

	var pair = $().add( container ).add( background );
	this._closeReg( function ( submitComplete ) {
		pair.animate(
			{ opacity: 0 },
			function () {
				pair.detach();

				$(window).off( 'resize.'+namespace );

				// Clear error messages "offline"
				that._clearDynamicInfo();
			}
		);
	} );

	// Close event handlers
	background.click( function () {
		that.blur();
	} );

	close.click( function () {
		that._close();
	} );

	this.bubblePosition();

	pair.animate( { opacity: 1 } );

	this._focus( fields, opts.focus );
	this._postopen( 'bubble' );

	return this;
};


/**
 * Reposition the editing bubble (`bubble()`) when it is visible. This can be
 * used to update the bubble position if other elements on the page change
 * position. Editor will automatically call this method on window resize.
 *
 * @return {Editor} Editor instance, for chaining
 */
Editor.prototype.bubblePosition = function ()
{
	var
		wrapper = $('div.DTE_Bubble'),
		liner = $('div.DTE_Bubble_Liner'),
		nodes = this.s.bubbleNodes;

	// Average the node positions to insert the container
	var position = { top: 0, left: 0, right: 0, bottom: 0 };

	$.each( nodes, function (i, node) {
		var pos = $(node).offset();

		position.top += pos.top;
		position.left += pos.left;
		position.right += pos.left + node.offsetWidth;
		position.bottom += pos.top + node.offsetHeight;
	} );

	position.top /= nodes.length;
	position.left /= nodes.length;
	position.right /= nodes.length;
	position.bottom /= nodes.length;

	var
		top = position.top,
		left = (position.left + position.right) / 2,
		width = liner.outerWidth(),
		visLeft = left - (width / 2),
		visRight = visLeft + width,
		docWidth = $(window).width(),
		padding = 15;

	wrapper.css( {
		top: top,
		left: left
	} );

	// Attempt to correct for overflow to the right of the document
	if ( visRight+padding > docWidth ) {
		var diff = visRight - docWidth;

		// If left overflowing, that takes priority
		liner.css( 'left', visLeft < padding ?
			-(visLeft-padding) :
			-(diff+padding)
		);
	}
	else {
		// Correct overflow to the left
		liner.css( 'left', visLeft < padding ? -(visLeft-padding) : 0 );
	}

	return this;
};


/**
 * Setup the buttons that will be shown in the footer of the form - calling this
 * method will replace any buttons which are currently shown in the form.
 *  @param {array|object} buttons A single button definition to add to the form or
 *    an array of objects with the button definitions to add more than one button.
 *    The options for the button definitions are fully defined by the
 *    {@link Editor.models.button} object.
 *  @param {string} buttons.label The text to put into the button. This can be any
 *    HTML string you wish as it will be rendered as HTML (allowing images etc to 
 *    be shown inside the button).
 *  @param {function} [buttons.fn] Callback function which the button is activated.
 *    For example for a 'submit' button you would call the {@link Editor#submit} method,
 *    while for a cancel button you would call the {@link Editor#close} method. Note that
 *    the function is executed in the scope of the Editor instance, so you can call
 *    the Editor's API methods using the `this` keyword.
 *  @param {string} [buttons.className] The CSS class(es) to apply to the button
 *    which can be useful for styling buttons which preform different functions
 *    each with a distinctive visual appearance.
 *  @return {Editor} Editor instance, for chaining
 */
Editor.prototype.buttons = function ( buttons )
{
	var that = this;

	if ( buttons === '_basic' ) {
		// Special string to create a basic button - undocumented
		buttons = [ {
			label: this.i18n[ this.s.action ].submit,
			fn: function () { this.submit(); }
		} ];
	}
	else if ( ! $.isArray( buttons ) ) {
		// Allow a single button to be passed in as an object with an array
		buttons = [ buttons ];
	}

	$(this.dom.buttons).empty();

	$.each( buttons, function ( i, btn ) {
		if ( typeof btn === 'string' ) {
			btn = {
				label: btn,
				fn: function () { this.submit(); }
			};
		}

		$( '<button/>', {
				'class': that.classes.form.button+(btn.className ? ' '+btn.className : '')
			} )
			.html( btn.label || '' )
			.attr( 'tabindex', 0 )
			.on( 'keyup', function (e) {
				if ( e.keyCode === 13 && btn.fn ) {
					btn.fn.call( that );
				}
			} )
			.on( 'keypress', function (e) {
				// Stop the browser activating the click event - if we don't
				// have this and the Ajax return is fast, the keyup in
				// `_formOptions()` might trigger another submit
				if ( e.keyCode === 13 ) {
					e.preventDefault();
				}
			} )
			.on( 'mousedown', function (e) {
				// Stop mouse giving focus - but keyboard still can
				e.preventDefault();
			} )
			.on( 'click', function (e) {
				e.preventDefault();

				if ( btn.fn ) {
					btn.fn.call( that );
				}
			} )
			.appendTo( that.dom.buttons );
	} );

	return this;
};


/**
 * Remove fields from the form (fields are those that have been added using the
 * {@link Editor#add} method or the `fields` initialisation option). A single,
 * multiple or all fields can be removed at a time based on the passed parameter.
 * Fields are identified by the `name` property that was given to each field
 * when added to the form.
 *  @param {string|array} [fieldName] Field or fields to remove from the form. If
 *    not given then all fields are removed from the form. If given as a string
 *    then the single matching field will be removed. If given as an array of
 *    strings, then all matching fields will be removed.
 *  @return {Editor} Editor instance, for chaining
 *
 *  @example
 *    // Clear the form of current fields and then add a new field 
 *    // before displaying a 'create' display
 *    editor.clear();
 *    editor.add( {
 *      "label": "User name",
 *      "name": "username"
 *    } );
 *    editor.create( "Create user" );
 *
 *  @example
 *    // Remove an individual field
 *    editor.clear( "username" );
 *
 *  @example
 *    // Remove multiple fields
 *    editor.clear( [ "first_name", "last_name" ] );
 */
Editor.prototype.clear = function ( fieldName )
{
	var that = this;
	var fields = this.s.fields;

	if ( !fieldName ) {
		// Empty the whole form
		$.each( fields, function (name) {
			that.clear( name );
		} );
	}
	else if ( $.isArray( fieldName ) ) {
		// Array of field names
		for ( var i=0, iLen=fieldName.length ; i<iLen ; i++ ) {
			this.clear( fieldName[i] );
		}
	}
	else {
		// Remove an individual form element
		fields[ fieldName ].destroy();
		delete fields[ fieldName ];

		var orderIdx = $.inArray( fieldName, this.s.order );
		this.s.order.splice( orderIdx, 1 );
	}

	return this;
};


/**
 * Close the form display.
 * 
 * Note that `close()` will close any of the three Editor form types (main,
 * bubble and inline).
 *
 *  @return {Editor} Editor instance, for chaining
 */
Editor.prototype.close = function ()
{
	this._close( false );

	return this;
};


/**
 * Create a new record - show the form that allows the user to enter information
 * for a new row and then subsequently submit that data.
 *  @param {boolean} [show=true] Show the form or not.
 * 
 *  @example
 *    // Show the create form with a submit button
 *    editor
 *      .title( 'Add new record' )
 *      .buttons( {
 *        "label": "Save",
 *        "fn": function () {
 *          this.submit();
 *        }
 *      } )
 *      .create();
 * 
 *  @example
 *    // Don't show the form and automatically submit it after programatically 
 *    // setting the values of fields (and using the field defaults)
 *    editor
 *      create()
 *      set( 'name',   'Test user' )
 *      set( 'access', 'Read only' )
 *      submit();
 */
Editor.prototype.create = function ( arg1, arg2, arg3, arg4 )
{
	var that = this;

	// Some other field in inline edit mode?
	if ( this._tidy( function () { that.create( arg1, arg2, arg3, arg4 ); } ) ) {
		return this;
	}

	var fields = this.s.fields;
	var argOpts = this._crudArgs( arg1, arg2, arg3, arg4 );

	this.s.action = "create";
	this.s.modifier = null;
	this.dom.form.style.display = 'block';

	this._actionClass();

	// Set the default for the fields
	$.each( fields, function ( name, field ) {
		field.set( field.def() );
	} );

	this._event( 'initCreate' );
	this._assembleMain();
	this._formOptions( argOpts.opts );

	argOpts.maybeOpen();

	return this;
};

/**
 * Create a dependent link between two or more fields. This method is used to
 * listen for a change in a field's value which will trigger updating of the
 * form. This update can consist of updating an options list, changing values
 * or making fields hidden / visible.
 *
 * @param {string} parent The name of the field to listen to changes from
 * @param {string|object|function} url Callback definition. This can be:
 *   * A string, which will be used as a URL to submit the request for update to
 *   * An object, which is used to extend an Ajax object for the request. The
 *     `url` parameter must be specified.
 *   * A function, which is used as a callback, allowing non-ajax updates.
 * @return {Editor} Editor instance, for chaining
 */
Editor.prototype.dependent = function ( parent, url, opts ) {
	var that = this;
	var field = this.field( parent );
	var ajaxOpts = {
		type: 'POST',
		dataType: 'json'
	};

	opts = $.extend( {
		event: 'change',
		data: null,
		preUpdate: null,
		postUpdate: null
	}, opts );

	var update = function ( json ) {
		if ( opts.preUpdate ) {
			opts.preUpdate( json );
		}

		// Field specific
		$.each( {
			labels:   'label',
			options:  'update',
			values:   'val',
			messages: 'message',
			errors:   'error'
		}, function ( jsonProp, fieldFn ) {
			if ( json[ jsonProp ] ) {
				$.each( json[ jsonProp ], function ( field, val ) {
					that.field( field )[ fieldFn ]( val );
				} );
			}
		} );

		// Form level
		$.each( [ 'hide', 'show', 'enable', 'disable' ], function ( i, key ) {
			if ( json[ key ] ) {
				that[ key ]( json[ key ] );
			}
		} );

		if ( opts.postUpdate ) {
			opts.postUpdate( json );
		}
	};

	field.input().on( opts.event, function () {
		var data = {};
		data.row = that._dataSource( 'get', that.modifier(), that.s.fields );
		data.values = that.val();

		if ( opts.data ) {
			var ret = opts.data( data );

			if ( ret ) {
				opts.data = ret;
			}
		}

		if ( typeof url === 'function' ) {
			var o = url( field.val(), data, update );

			if ( o ) {
				update( o );
			}
		}
		else {
			if ( $.isPlainObject( url ) ) {
				$.extend( ajaxOpts, url );
			}
			else {
				ajaxOpts.url = url;
			}

			$.ajax( $.extend( ajaxOpts, {
				url: url,
				data: data,
				success: update
			} ) );
		}
	} );

	return this;
};


/**
 * Disable one or more field inputs, disallowing subsequent user interaction with the 
 * fields until they are re-enabled.
 *  @param {string|array} name The field name (from the `name` parameter given when
 *   originally setting up the field) to disable, or an array of field names to disable
 *   multiple fields with a single call.
 *  @return {Editor} Editor instance, for chaining
 * 
 *  @example
 *    // Show a 'create' record form, but with a field disabled
 *    editor.disable( 'account_type' );
 *    editor.create( 'Add new user', {
 *      "label": "Save",
 *      "fn": function () { this.submit(); }
 *    } );
 * 
 *  @example
 *    // Disable multiple fields by using an array of field names
 *    editor.disable( ['account_type', 'access_level'] );
 */
Editor.prototype.disable = function ( name )
{
	var fields = this.s.fields;

	if ( ! $.isArray( name ) ) {
		name = [ name ];
	}

	$.each( name, function ( i, n ) {
		fields[ n ].disable();
	} );

	return this;
};


/**
 * Display, or remove the editing form from the display
 *  @param {boolean} show Show (`true`) or hide (`false`)
 *  @return {Editor} Editor instance, for chaining
 */
Editor.prototype.display = function ( show )
{
	if ( show === undefined ) {
		return this.s.displayed;
	}
	return this[ show ? 'open' : 'close' ]();
};


/**
 * Fields which are currently displayed
 *  @return {string[]} Field names that are shown
 */
Editor.prototype.displayed = function ()
{
	return $.map( this.s.fields, function ( field, name ) {
		return field.displayed() ? name : null;
	} );
};


/**
 * Edit a record - show the form, pre-populated with the data that is in the given 
 * DataTables row, that allows the user to enter information for the row to be modified
 * and then subsequently submit that data.
 *  @param {node} row The TR element from the DataTable that is to be edited
 *  @param {boolean} [show=true] Show the form or not.
 *  @return {Editor} Editor instance, for chaining
 * 
 *  @example
 *    // Show the edit form for the first row in the DataTable with a submit button
 *    editor.edit( $('#example tbody tr:eq(0)')[0], 'Edit record', {
 *      "label": "Update",
 *      "fn": function () { this.submit(); }
 *    } );
 *
 *  @example
 *    // Use the title and buttons API methods to show an edit form (this provides
 *    // the same result as example above, but is a different way of achieving it
 *    editor.title( 'Edit record' );
 *    editor.buttons( {
 *      "label": "Update",
 *      "fn": function () { this.submit(); }
 *    } );
 *    editor.edit( $('#example tbody tr:eq(0)')[0] );
 * 
 *  @example
 *    // Automatically submit an edit without showing the user the form
 *    editor.edit( TRnode, null, null, false );
 *    editor.set( 'name', 'Updated name' );
 *    editor.set( 'access', 'Read only' );
 *    editor.submit();
 */
Editor.prototype.edit = function ( row, arg1, arg2, arg3, arg4 )
{
	var that = this;

	// Some other field in inline edit mode?
	if ( this._tidy( function () { that.edit( row, arg1, arg2, arg3, arg4 ); } ) ) {
		return this;
	}

	var fields = this.s.fields;
	var argOpts = this._crudArgs( arg1, arg2, arg3, arg4 );

	this._edit( row, 'main' );
	this._assembleMain();
	this._formOptions( argOpts.opts );

	argOpts.maybeOpen();

	return this;
};


/**
 * Enable one or more field inputs, restoring user interaction with the fields.
 *  @param {string|array} name The field name (from the `name` parameter given when
 *   originally setting up the field) to enable, or an array of field names to enable
 *   multiple fields with a single call.
 *  @return {Editor} Editor instance, for chaining
 * 
 *  @example
 *    // Show a 'create' form with buttons which will enable and disable certain fields
 *    editor.create( 'Add new user', [
 *      {
 *        "label": "User name only",
 *        "fn": function () {
 *          this.enable('username');
 *          this.disable( ['first_name', 'last_name'] );
 *        }
 *      }, {
 *        "label": "Name based",
 *        "fn": function () {
 *          this.disable('username');
 *          this.enable( ['first_name', 'last_name'] );
 *        }
 *      }, {
 *        "label": "Submit",
 *        "fn": function () { this.submit(); }
 *      }
 *    );
 */
Editor.prototype.enable = function ( name )
{
	var fields = this.s.fields;

	if ( ! $.isArray( name ) ) {
		name = [ name ];
	}

	$.each( name, function ( i, n ) {
		fields[ n ].enable();
	} );

	return this;
};


/**
 * Show that a field, or the form globally, is in an error state. Note that
 * errors are cleared on each submission of the form.
 *  @param {string} [name] The name of the field that is in error. If not
 *    given then the global form error display is used.
 *  @param {string} msg The error message to show
 *  @return {Editor} Editor instance, for chaining
 * 
 *  @example
 *    // Show an error if the field is required
 *    editor.create( 'Add new user', {
 *      "label": "Submit",
 *      "fn": function () {
 *        if ( this.get('username') === '' ) {
 *          this.error( 'username', 'A user name is required' );
 *          return;
 *        }
 *        this.submit();
 *      }
 *    } );
 * 
 *  @example
 *    // Show a field and a global error for a required field
 *    editor.create( 'Add new user', {
 *      "label": "Submit",
 *      "fn": function () {
 *        if ( this.get('username') === '' ) {
 *          this.error( 'username', 'A user name is required' );
 *          this.error( 'The data could not be saved because it is incomplete' );
 *          return;
 *        }
 *        this.submit();
 *      }
 *    } );
 */
Editor.prototype.error = function ( name, msg )
{
	if ( msg === undefined ) {
		// Global error
		this._message( this.dom.formError, name );
	}
	else {
		// Field error
		this.s.fields[ name ].error( msg );
	}

	return this;
};


/**
 * Get a field object, configured for a named field, which can then be
 * manipulated through its API. This function effectively acts as a
 * proxy to the field extensions, allowing easy access to the methods
 * for a named field. The methods that are available depend upon the field
 * type plug-in for Editor.
 *
 *   @param {string} name Field name to be obtained
 *   @return {Editor.Field} Field instance
 *
 *   @example
 *     // Update the values available in a select list
 *     editor.field('island').update( [
 *       'Lewis and Harris',
 *       'South Uist',
 *       'North Uist',
 *       'Benbecula',
 *       'Barra'
 *     ] );
 *
 *   @example
 *     // Equivalent calls
 *     editor.field('name').set('John Smith');
 *
 *     // results in the same action as:
 *     editor.set('John Smith');
 */
Editor.prototype.field = function ( name )
{
	return this.s.fields[ name ];
};


/**
 * Get a list of the fields that are used by the Editor instance.
 *  @returns {string[]} Array of field names
 * 
 *  @example
 *    // Get current fields and move first item to the end
 *    var fields = editor.fields();
 *    var first = fields.shift();
 *    fields.push( first );
 *    editor.order( fields );
 */
Editor.prototype.fields = function ()
{
	return $.map( this.s.fields, function ( field, name ) {
		return name;
	} );
};


/**
 * Get the value of a field
 *  @param {string|array} [name] The field name (from the `name` parameter given
 *    when originally setting up the field) to disable. If not given, then an
 *    object of fields is returned, with the value of each field from the
 *    instance represented in the array (the object properties are the field
 *    names). Also an array of field names can be given to get a collection of
 *    data from the form.
 *  @returns {*|object} Value from the named field
 * 
 *  @example
 *    // Client-side validation - check that a field has been given a value 
 *    // before submitting the form
 *    editor.create( 'Add new user', {
 *      "label": "Submit",
 *      "fn": function () {
 *        if ( this.get('username') === '' ) {
 *          this.error( 'username', 'A user name is required' );
 *          return;
 *        }
 *        this.submit();
 *      }
 *    } );
 */
Editor.prototype.get = function ( name )
{
	var fields = this.s.fields;

	if ( ! name ) {
		name = this.fields();
	}

	if ( $.isArray( name ) ) {
		var out = {};

		$.each( name, function (i, n) {
			out[n] = fields[n].get();
		} );

		return out;
	}

	return fields[ name ].get();
};


/**
 * Remove a field from the form display. Note that the field will still be submitted
 * with the other fields in the form, but it simply won't be visible to the user.
 *  @param {string|array} [name] The field name (from the `name` parameter given when
 *   originally setting up the field) to hide or an array of names. If not given then all 
 *   fields are hidden.
 *  @param {boolean} [animate=true] Animate if visible
 *  @return {Editor} Editor instance, for chaining
 * 
 *  @example
 *    // Show a 'create' record form, but with some fields hidden
 *    editor.hide( 'account_type' );
 *    editor.hide( 'access_level' );
 *    editor.create( 'Add new user', {
 *      "label": "Save",
 *      "fn": function () { this.submit(); }
 *    } );
 *
 *  @example
 *    // Show a single field by hiding all and then showing one
 *    editor.hide();
 *    editor.show('access_type');
 */
Editor.prototype.hide = function ( names, animate )
{
	if ( ! names ) {
		names = this.fields();
	}
	else if ( ! $.isArray( names ) ) {
		names = [ names ];
	}

	var fields = this.s.fields;
	$.each( names, function (i, n) {
		fields[ n ].hide( animate );
	} );

	return this;
};


/**
 * Inline editing for a single field. This method provides a method to allow
 * end users to very quickly edit fields in place. For example, a user could
 * simply click on a cell in a table, the contents of which would be replaced
 * with the editing input field for that cell.
 *
 * @param {string|node|DataTables.Api|cell-selector} cell The cell or field to
 *   be edited (note that for table editing this must be a cell - for standalone
 *   editing it can also be the field name to edit).
 * @param {string} [fieldName] The field name to be edited. This parameter is
 *   optional. If not provided, Editor will attempt to resolve the correct field
 *   from the cell / element given as the first parameter. If it is unable to do
 *   so, it will throw an error.
 * @param {object} [opts] Inline editing options:
 *   * `submitOnReturn` (default = `true`) - Submit the edit on key press
 *   * `submitOnBlur` (default = `false`) - Submit when the field is blurred
 *   * `append` (default = `false`) - Element to be added to the container after
 *     the field. This can be used to add a submit button for example. This
 *     parameter can be given as `true` in which case Editor will append a
 *     `<button>` element which will submit the input when clicked.
 *  @return {Editor} Editor instance, for chaining
 */
Editor.prototype.inline = function ( cell, fieldName, opts )
{
	var that = this;

	// Argument shifting
	if ( $.isPlainObject( fieldName ) ) {
		opts = fieldName;
		fieldName = undefined;
	}

	opts = $.extend( {}, this.s.formOptions.inline, opts );

	// Get the node, edit id and field from the data source
	var ind = this._dataSource( 'individual', cell, fieldName, this.s.fields );
	var node = $(ind.node);
	var field = ind.field;

	// Already in edit mode for this cell?
	if ( $('div.DTE_Field', node).length ) {
		return this;
	}

	// Some other field in inline edit mode?
	if ( this._tidy( function () { that.inline( cell, fieldName, opts ); } ) ) {
		return this;
	}

	// Start a full row edit, but don't display - we will be showing the field
	this._edit( ind.edit, 'inline' );
	var namespace = this._formOptions( opts );

	var ret = this._preopen( 'inline' );
	if ( ! ret ) {
		return this;
	}

	// Remove from DOM, keeping event handlers, and include text nodes in remove
	var children = node.contents().detach();

	node.append( $(
		'<div class="DTE DTE_Inline">'+
			'<div class="DTE_Inline_Field"/>'+
			'<div class="DTE_Inline_Buttons"/>'+
		'</div>'
	) );

	node.find('div.DTE_Inline_Field').append( field.node() );

	if ( opts.buttons ) {
		// Use prepend for the CSS, so we can float the buttons right
		node.find('div.DTE_Inline_Buttons').append( this.dom.buttons );
	}

	this._closeReg( function ( submitComplete ) {
		$(document).off( 'click'+namespace );

		// If there was no submit, we need to put the DOM back as it was. If
		// there was a submit, the write of the new value will set the DOM to
		// how it should be
		if ( ! submitComplete ) {
			node.contents().detach();
			node.append( children );
		}

		// Clear error messages "offline"
		that._clearDynamicInfo();
	} );

	// Submit and blur actions
	setTimeout( function () {
		$(document).on( 'click'+namespace, function ( e ) {
			// Was the click inside or owned by the editing node? If not, then
			// come out of editing mode.

			// andSelf is deprecated in jQ1.8, but we want 1.7 compat
			var back = $.fn.addBack ? 'addBack' : 'andSelf';

			if ( ! field._typeFn( 'owns', e.target ) && 
				 $.inArray( node[0], $(e.target).parents()[ back ]() ) === -1 )
			{
				that.blur();
			}
		} );
	}, 0 );

	this._focus( [ field ], opts.focus );
	this._postopen( 'inline' );

	return this;
};


/**
 * Show an information message for the form as a whole, or for an individual
 * field. This can be used to provide helpful information to a user about an
 * individual field, or more typically the form (for example when deleting
 * a record and asking for confirmation).
 *  @param {string} [name] The name of the field to show the message for. If not
 *    given then a global message is shown for the form
 *  @param {string} msg The message to show
 *  @return {Editor} Editor instance, for chaining
 * 
 *  @example
 *    // Show a global message for a 'create' form
 *    editor.message( 'Add a new user to the database by completing the fields below' );
 *    editor.create( 'Add new user', {
 *      "label": "Submit",
 *      "fn": function () { this.submit(); }
 *    } );
 * 
 *  @example
 *    // Show a message for an individual field when a 'help' icon is clicked on
 *    $('#user_help').click( function () {
 *      editor.message( 'user', 'The user name is what the system user will login with' );
 *    } );
 */
Editor.prototype.message = function ( name, msg )
{
	if ( msg === undefined ) {
		// Global message
		this._message( this.dom.formInfo, name );
	}
	else {
		// Field message
		this.s.fields[ name ].message( msg );
	}

	return this;
};


/**
 * Get which mode of operation the Editor form is in
 *  @return {string} `create`, `edit`, `remove` or `null` if no active state.
 */
Editor.prototype.mode = function ()
{
	return this.s.action;
};


/**
 * Get the modifier that was used to trigger the edit or delete action.
 *  @return {*} The identifier that was used for the editing / remove method
 *    called.
 */
Editor.prototype.modifier = function ()
{
	return this.s.modifier;
};


/**
 * Get the container node for an individual field.
 *  @param {string|array} name The field name (from the `name` parameter given
 *   when originally setting up the field) to get the DOM node for.
 *  @return {node|array} Field container node
 * 
 *  @example
 *    // Dynamically add a class to a field's container
 *    $(editor.node( 'account_type' )).addClass( 'account' );
 */
Editor.prototype.node = function ( name )
{
	var fields = this.s.fields;

	if ( ! name ) {
		name = this.order();
	}

	return $.isArray( name ) ?
		$.map( name, function (n) {
			return fields[ n ].node();
		} ) :
		fields[ name ].node();
};


/**
 * Remove a bound event listener to the editor instance. This method provides a 
 * shorthand way of binding jQuery events that would be the same as writing 
 * `$(editor).off(...)` for convenience.
 *  @param {string} name Event name to remove the listeners for - event names are
 *    defined by {@link Editor}.
 *  @param {function} [fn] The function to remove. If not given, all functions which
 *    are assigned to the given event name will be removed.
 *  @return {Editor} Editor instance, for chaining
 *
 *  @example
 *    // Add an event to alert when the form is shown and then remove the listener
 *    // so it will only fire once
 *    editor.on( 'open', function () {
 *      alert('Form displayed!');
 *      editor.off( 'open' );
 *    } );
 */
Editor.prototype.off = function ( name, fn )
{
	$(this).off( this._eventName( name ), fn );

	return this;
};


/**
 * Listen for an event which is fired off by Editor when it performs certain
 * actions. This method provides a shorthand way of binding jQuery events that
 * would be the same as writing  `$(editor).on(...)` for convenience.
 *  @param {string} name Event name to add the listener for - event names are
 *    defined by {@link Editor}.
 *  @param {function} fn The function to run when the event is triggered.
 *  @return {Editor} Editor instance, for chaining
 *
 *  @example
 *    // Log events on the console when they occur
 *    editor.on( 'open', function () { console.log( 'Form opened' ); } );
 *    editor.on( 'close', function () { console.log( 'Form closed' ); } );
 *    editor.on( 'submit', function () { console.log( 'Form submitted' ); } );
 */
Editor.prototype.on = function ( name, fn )
{
	$(this).on( this._eventName( name ), fn );

	return this;
};


/**
 * Listen for a single event event which is fired off by Editor when it performs
 * certain actions. This method provides a shorthand way of binding jQuery
 * events that would be the same as writing  `$(editor).one(...)` for
 * convenience.
 *  @param {string} name Event name to add the listener for - event names are
 *    defined by {@link Editor}.
 *  @param {function} fn The function to run when the event is triggered.
 *  @return {Editor} Editor instance, for chaining
 */
Editor.prototype.one = function ( name, fn )
{
	$(this).one( this._eventName( name ), fn );

	return this;
};


/**
 * Display the main form editor to the end user in the web-browser.
 * 
 * Note that the `close()` method will close any of the three Editor form types
 * (main, bubble and inline), but this method will open only the main type.
 *  @return {Editor} Editor instance, for chaining
 * 
 *  @example
 *    // Build a 'create' form, but don't display it until some values have
 *    // been set. When done, then display the form.
 *    editor.create( 'Create user', {
 *      "label": "Submit",
 *      "fn": function () { this.submit(); }
 *    }, false );
 *    editor.set( 'name', 'Test user' );
 *    editor.set( 'access', 'Read only' );
 *    editor.open();
 */
Editor.prototype.open = function ()
{
	var that = this;

	// Insert the display elements in order
	this._displayReorder();

	// Define how to do a close
	this._closeReg( function ( submitComplete ) {
		that.s.displayController.close( that, function () {
			that._clearDynamicInfo();
		} );
	} );

	// Run the standard open with common events
	var ret = this._preopen( 'main' );
	if ( ! ret ) {
		return this;
	}

	this.s.displayController.open( this, this.dom.wrapper );
	this._focus(
		$.map( this.s.order, function (name) {
			return that.s.fields[ name ];
		} ),
		this.s.editOpts.focus
	);
	this._postopen( 'main' );

	return this;
};


/**
 * Get or set the ordering of fields, as they are displayed in the form. When used as
 * a getter, the field names are returned in an array, in their current order, and when
 * used as a setting you can alter the field ordering by passing in an array with all
 * field names in their new order.
 * 
 * Note that all fields *must* be included when reordering, and no additional fields can 
 * be added here (use {@link Editor#add} to add more fields). Finally, for setting the 
 * order, you can pass an array of the field names, or give the field names as individual
 * parameters (see examples below).
 *  @param {array|string} [set] Field order to set.
 *  @return {Editor} Editor instance, for chaining
 * 
 *  @example
 *    // Get field ordering
 *    var order = editor.order();
 * 
 *  @example
 *    // Set the field order
 *    var order = editor.order();
 *    order.unshift( order.pop() ); // move the last field into the first position
 *    editor.order( order );
 * 
 *  @example
 *    // Set the field order as arguments
 *    editor.order( "pupil", "grade", "dept", "exam-board" );
 *
 */
Editor.prototype.order = function ( set /*, ... */ )
{
	if ( !set ) {
		return this.s.order;
	}

	// Allow new layout to be passed in as arguments
	if ( arguments.length && ! $.isArray( set ) ) {
		set = Array.prototype.slice.call(arguments);
	}

	// Sanity check - array must exactly match the fields we have available
	if ( this.s.order.slice().sort().join('-') !== set.slice().sort().join('-') ) {
		throw "All fields, and no additional fields, must be provided for ordering.";
	}

	// Copy the new array into the order (so the reference is maintained)
	$.extend( this.s.order, set );

	this._displayReorder();

	return this;
};


/**
 * Remove (delete) entries from the table. The rows to remove are given as
 * either a single DOM node or an array of DOM nodes (including a jQuery
 * object).
 *  @param {node|array} rows The row, or array of nodes, to delete
 *  @param {boolean} [show=true] Show the form or not.
 *  @return {Editor} Editor instance, for chaining
 * 
 *  @example
 *    // Delete a given row with a message to let the user know exactly what is
 *    // happening
 *    editor.message( "Are you sure you want to remove this row?" );
 *    editor.remove( row_to_delete, 'Delete row', {
 *      "label": "Confirm",
 *      "fn": function () { this.submit(); }
 *    } );
 * 
 *  @example
 *    // Delete the first row in a table without asking the user for confirmation
 *    editor.remove( '', $('#example tbody tr:eq(0)')[0], null, false );
 *    editor.submit();
 * 
 *  @example
 *    // Delete all rows in a table with a submit button
 *    editor.remove( $('#example tbody tr'), 'Delete all rows', {
 *      "label": "Delete all",
 *      "fn": function () { this.submit(); }
 *    } );
 */
Editor.prototype.remove = function ( rows, arg1, arg2, arg3, arg4 )
{
	var that = this;

	// Some other field in inline edit mode?
	if ( this._tidy( function () { that.remove( rows, arg1, arg2, arg3, arg4 ); } ) ) {
		return this;
	}

	// Allow a single row node to be passed in to remove, Can't use $.isArray
	// as we also allow array like objects to be passed in (API, jQuery)
	if ( rows.length === undefined ) {
		rows = [ rows ];
	}

	var argOpts = this._crudArgs( arg1, arg2, arg3, arg4 );

	this.s.action = "remove";
	this.s.modifier = rows;
	this.dom.form.style.display = 'none';

	this._actionClass();

	this._event( 'initRemove', [
		this._dataSource( 'node', rows ),
		this._dataSource( 'get', rows, this.s.fields ),
		rows
	] );
	this._assembleMain();
	this._formOptions( argOpts.opts );

	argOpts.maybeOpen();

	var opts = this.s.editOpts;
	if ( opts.focus !== null ) {
		$('button', this.dom.buttons).eq( opts.focus ).focus();
	}

	return this;
};


/**
 * Set the value of a field
 *  @param {string|object} name The field name (from the `name` parameter given
 *    when originally setting up the field) to set the value of. If given as an
 *    object the object parameter name will be the value of the field to set and
 *    the value the value to set for the field.
 *  @param {*} [val] The value to set the field to. The format of the value will
 *    depend upon the field type. Not required if the first parameter is given
 *    as an object.
 *  @return {Editor} Editor instance, for chaining
 *
 *  @example
 *    // Set the values of a few fields before then automatically submitting the form
 *    editor.create( null, null, false );
 *    editor.set( 'name', 'Test user' );
 *    editor.set( 'access', 'Read only' );
 *    editor.submit();
 */
Editor.prototype.set = function ( set, val )
{
	var fields = this.s.fields;

	if ( ! $.isPlainObject( set ) ) {
		var o = {};
		o[ set ] = val;
		set = o;
	}

	$.each( set, function (n, v) {
		fields[ n ].set( v );
	} );

	return this;
};


/**
 * Show a field in the display that was previously hidden.
 *  @param {string|array} [names] The field name (from the `name` parameter
 *   given when originally setting up the field) to make visible, or an array of
 *   field names to make visible. If not given all fields are shown.
 *  @param {boolean} [animate=true] Animate if visible
 *  @return {Editor} Editor instance, for chaining
 * 
 *  @example
 *    // Shuffle the fields that are visible, hiding one field and making two
 *    // others visible before then showing the {@link Editor#create} record form.
 *    editor.hide( 'username' );
 *    editor.show( 'account_type' );
 *    editor.show( 'access_level' );
 *    editor.create( 'Add new user', {
 *      "label": "Save",
 *      "fn": function () { this.submit(); }
 *    } );
 *
 *  @example
 *    // Show all fields
 *    editor.show();
 */
Editor.prototype.show = function ( names, animate )
{
	if ( ! names ) {
		names = this.fields();
	}
	else if ( ! $.isArray( names ) ) {
		names = [ names ];
	}

	var fields = this.s.fields;
	$.each( names, function (i, n) {
		fields[ n ].show( animate );
	} );

	return this;
};


/**
 * Submit a form to the server for processing. The exact action performed will depend
 * on which of the methods {@link Editor#create}, {@link Editor#edit} or 
 * {@link Editor#remove} were called to prepare the form - regardless of which one is 
 * used, you call this method to submit data.
 *  @param {function} [successCallback] Callback function that is executed once the
 *    form has been successfully submitted to the server and no errors occurred.
 *  @param {function} [errorCallback] Callback function that is executed if the
 *    server reports an error due to the submission (this includes a JSON formatting
 *    error should the error return invalid JSON).
 *  @param {function} [formatdata] Callback function that is passed in the data
 *    that will be submitted to the server, allowing pre-formatting of the data,
 *    removal of data or adding of extra fields.
 *  @param {boolean} [hide=true] When the form is successfully submitted, by default
 *    the form display will be hidden - this option allows that to be overridden.
 *  @return {Editor} Editor instance, for chaining
 *
 *  @example
 *    // Submit data from a form button
 *    editor.create( 'Add new record', {
 *      "label": "Save",
 *      "fn": function () {
 *        this.submit();
 *      }
 *    } );
 *
 *  @example
 *    // Submit without showing the user the form
 *    editor.create( null, null, false );
 *    editor.submit();
 *
 *  @example
 *    // Provide success and error callback methods
 *    editor.create( 'Add new record', {
 *      "label": "Save",
 *      "fn": function () {
 *        this.submit( function () {
 *            alert( 'Form successfully submitted!' );
 *          }, function () {
 *            alert( 'Form  encountered an error :-(' );
 *          }
 *        );
 *      }
 *    } );
 *  
 *  @example
 *    // Add an extra field to the data
 *    editor.create( 'Add new record', {
 *      "label": "Save",
 *      "fn": function () {
 *        this.submit( null, null, function (data) {
 *          data.extra = "Extra information";
 *        } );
 *      }
 *    } );
 *
 *  @example
 *    // Don't hide the form immediately - change the title and then close the form
 *    // after a small amount of time
 *    editor.create( 'Add new record', {
 *      "label": "Save",
 *      "fn": function () {
 *        this.submit( 
 *          function () {
 *            var that = this;
 *            this.title( 'Data successfully added!' );
 *            setTimeout( function () {
 *              that.close();
 *            }, 1000 );
 *          },
 *          null,
 *          null,
 *          false
 *        );
 *      }
 *    } );
 *    
 */
Editor.prototype.submit = function ( successCallback, errorCallback, formatdata, hide )
{
	var
		that = this,
		fields = this.s.fields,
		errorFields = [],
		errorReady = 0,
		sent = false;

	if ( this.s.processing || ! this.s.action ) {
		return this;
	}
	this._processing( true );

	// If there are fields in error, we want to wait for the error notification
	// to be cleared before the form is submitted - errorFields tracks the
	// fields which are in the error state, while errorReady tracks those which
	// are ready to submit
	var send = function () {
		if ( errorFields.length !== errorReady || sent ) {
			return;
		}

		sent = true;
		that._submit( successCallback, errorCallback, formatdata, hide );
	};

	// Remove the global error (don't know if the form is still in an error
	// state!)
	this.error();

	// Count how many fields are in error
	$.each( fields, function ( name, field ) {
		if ( field.inError() ) {
			errorFields.push( name );
		}
	} );

	// Remove the error display
	$.each( errorFields, function ( i, name ) {
		fields[ name ].error('', function () {
			errorReady++;
			send();
		} );
	} );

	send();

	return this;
};


/**
 * Set the title of the form
 *  @param {string} title The title to give to the form
 *  @return {Editor} Editor instance, for chaining
 *
 *  @example
 *    // Create an edit display used the title, buttons and edit methods (note that
 *    // this is just an example, typically you would use the parameters of the edit
 *    // method to achieve this.
 *    editor.title( 'Edit record' );
 *    editor.buttons( {
 *      "label": "Update",
 *      "fn": function () { this.submit(); }
 *    } );
 *    editor.edit( TR_to_edit );
 *
 *  @example
 *    // Show a create form, with a timer for the duration that the form is open
 *    editor.create( 'Add new record - time on form: 0s', {
 *      "label": "Save",
 *      "fn": function () { this.submit(); }
 *    } );
 *    
 *    // Add an event to the editor to stop the timer when the display is removed
 *    var runTimer = true;
 *    var timer = 0;
 *    editor.on( 'close', function () {
 *      runTimer = false;
 *      editor.off( 'close' );
 *    } );
 *    // Start the timer running
 *    updateTitle();
 *
 *    // Local function to update the title once per second
 *    function updateTitle() {
 *      editor.title( 'Add new record - time on form: '+timer+'s' );
 *      timer++;
 *      if ( runTimer ) {
 *        setTimeout( function() {
 *          updateTitle();
 *        }, 1000 );
 *      }
 *    }
 */
Editor.prototype.title = function ( title )
{
	var header = $(this.dom.header).children( 'div.'+this.classes.header.content );

	if ( title === undefined ) {
		return header.html();
	}

	header.html( title );

	return this;
};


/**
 * Get or set the value of a specific field, or get the value of all fields in
 * the form.
 *
 * @param {string|array} [names] The field name(s) to get or set the value of.
 *   If not given, then the value of all fields will be obtained.
 * @param {*} [value] Value to set
 * @return {Editor|object|*} Editor instance, for chaining if used as a setter,
 *   an object containing the values of the requested fields if used as a
 *   getter with multiple fields requested, or the value of the requested field
 *   if a single field is requested.
 */
Editor.prototype.val = function ( field, value )
{
	if ( value === undefined ) {
		return this.get( field ); // field can be undefined to get all
	}

	return this.set( field, value );
};


/*
 * DataTables 1.10 API integration. Provides the ability to control basic Editor
 * aspects from the DataTables API. Full control does of course require use of
 * the Editor API though.
 */

function __getInst( api ) {
	var ctx = api.context[0];
	return ctx.oInit.editor || ctx._editor;
}

// Set sensible defaults for the editing options
function __setBasic( inst, opts, type, plural ) {
	if ( ! opts ) {
		opts = {};
	}

	if ( opts.buttons === undefined ) {
		opts.buttons = '_basic';
	}

	if ( opts.title === undefined ) {
		opts.title = inst.i18n[ type ].title;
	}

	if ( opts.message === undefined ) {
		if ( type === 'remove' ) {
			var confirm = inst.i18n[ type ].confirm;
			opts.message = plural!==1 ? confirm._.replace(/%d/, plural) : confirm['1'];
		}
		else {
			opts.message = '';
		}
	}

	return opts;
}

var __dtApiRet = DataTable.Api.register;

__dtApiRet( 'editor()', function () {
	return __getInst( this );
} );

// Row editing
__dtApiRet( 'row.create()', function ( opts ) {
	// main
	var inst = __getInst( this );
	inst.create( __setBasic( inst, opts, 'create' ) );
} );

__dtApiRet( 'row().edit()', function ( opts ) {
	// main
	var inst = __getInst( this );
	inst.edit( this[0][0], __setBasic( inst, opts, 'edit' ) );
} );

__dtApiRet( 'row().delete()', function ( opts ) {
	// main
	var inst = __getInst( this );
	inst.remove( this[0][0], __setBasic( inst, opts, 'remove', 1 ) );
} );

__dtApiRet( 'rows().delete()', function ( opts ) {
	// main
	var inst = __getInst( this );
	inst.remove( this[0], __setBasic( inst, opts, 'remove', this[0].length ) );
} );

__dtApiRet( 'cell().edit()', function ( opts ) {
	// inline
	__getInst( this ).inline( this[0][0], opts );
} );

__dtApiRet( 'cells().edit()', function ( opts ) {
	// bubble
	__getInst( this ).bubble( this[0], opts );
} );


/**
 * Obtain label / value pairs of data from a data source, be it an array or
 * object, for use in an input that requires label / value pairs such as
 * `select`, `radio` and `checkbox` inputs.
 *
 * A callback function is triggered for each label / value pair found, so the
 * caller can add it to the input as required.
 *
 * @static
 * @param {object|array} An object or array of data to iterate over getting the
 *     label / value pairs.
 * @param {object} props When an array of objects is passed in as the data
 *     source by default the label will be read from the `label` property and
 *     the value from the `value` property of the object. This option can alter
 *     that behaviour.
 * @param {function} fn Callback function. Takes three parameters: the label,
 *      the value and the iterator index.
 */
Editor.pairs = function ( data, props, fn )
{
	var i, ien, dataPoint;

	// Define default properties to read the data from if using an object.
	// The passed in `props` object and override.
	props = $.extend( {
		label: 'label',
		value: 'value'
	}, props );

	if ( $.isArray( data ) ) {
		// As an array, we iterate each item which can be an object or value
		for ( i=0, ien=data.length ; i<ien ; i++ ) {
			dataPoint = data[i];

			if ( $.isPlainObject( dataPoint ) ) {
				fn( 
					dataPoint[ props.value ] === undefined ?
						dataPoint[ props.label ] :
						dataPoint[ props.value ],
					dataPoint[ props.label ],
					i
				);
			}
			else {
				fn( dataPoint, dataPoint, i );
			}
		}
	}
	else {
		// As an object the key is the label and the value is the value
		i = 0;

		$.each( data, function ( key, val ) {
			fn( val, key, i );
			i++;
		} );
	}
};


/**
 * Make a string safe to use as a DOM ID. This is primarily for use by field
 * plug-in authors.
 *
 * @static
 * @param {string} String to make safe
 * @param {string} Safe string
 */
Editor.safeId = function ( id )
{
	return id.replace('.', '-');
};



/**
 * Editor constructor - take the developer configuration and apply it to the instance.
 *  @param {object} init The initialisation options provided by the developer - see
 *    {@link Editor.defaults} for a full list of options.
 *  @private
 */
Editor.prototype._constructor = function ( init )
{
	init = $.extend( true, {}, Editor.defaults, init );
	this.s = $.extend( true, {}, Editor.models.settings, {
		table:      init.domTable || init.table,
		dbTable:    init.dbTable || null, // legacy
		ajaxUrl:    init.ajaxUrl,
		ajax:       init.ajax,
		idSrc:      init.idSrc,
		dataSource: init.domTable || init.table ?
			Editor.dataSources.dataTable :
			Editor.dataSources.html,
		formOptions: init.formOptions
	} );
	this.classes = $.extend( true, {}, Editor.classes );
	this.i18n = init.i18n;

	var that = this;
	var classes = this.classes;

	this.dom = {
		"wrapper": $(
			'<div class="'+classes.wrapper+'">'+
				'<div data-dte-e="processing" class="'+classes.processing.indicator+'"></div>'+
				'<div data-dte-e="body" class="'+classes.body.wrapper+'">'+
					'<div data-dte-e="body_content" class="'+classes.body.content+'"/>'+
				'</div>'+
				'<div data-dte-e="foot" class="'+classes.footer.wrapper+'">'+
					'<div class="'+classes.footer.content+'"/>'+
				'</div>'+
			'</div>'
		)[0],
		"form": $(
			'<form data-dte-e="form" class="'+classes.form.tag+'">'+
				'<div data-dte-e="form_content" class="'+classes.form.content+'"/>'+
			'</form>'
		)[0],
		"formError":   $('<div data-dte-e="form_error" class="'+classes.form.error+'"/>')[0],
		"formInfo":    $('<div data-dte-e="form_info" class="'+classes.form.info+'"/>')[0],
		"header":      $('<div data-dte-e="head" class="'+classes.header.wrapper+'"><div class="'+classes.header.content+'"/></div>')[0],
		"buttons":     $('<div data-dte-e="form_buttons" class="'+classes.form.buttons+'"/>')[0]
	};

	// Customise the TableTools buttons with the i18n settings - worth noting that
	// this could easily be done outside the Editor instance, but this makes things
	// a bit easier to understand and more cohesive. Also worth noting that when
	// there are two or more Editor instances, the init sequence should be
	// Editor / DataTables, Editor / DataTables etc, since the value of these button
	// instances matter when you create the TableTools buttons for the DataTable.
	if ( $.fn.dataTable.TableTools ) {
		var ttButtons = $.fn.dataTable.TableTools.BUTTONS;
		var i18n = this.i18n;

		$.each(['create', 'edit', 'remove'], function (i, val) {
			ttButtons['editor_'+val].sButtonText = i18n[val].button;
		} );
	}

	// Bind callback methods
	$.each( init.events, function (evt, fn) {
		that.on( evt, function () {
			// When giving events in the constructor the event argument was not
			// given in 1.2-, so we remove it here. This is solely for
			// backwards compatibility as the events in the initialisation are
			// not documented in 1.3+.
			var args = Array.prototype.slice.call(arguments);
			args.shift();
			fn.apply( that, args );
		} );
	} );

	// Cache the DOM nodes
	var dom = this.dom;
	var wrapper = dom.wrapper;
	dom.formContent   = _editor_el('form_content', dom.form)[0];
	dom.footer        = _editor_el('foot', wrapper)[0];
	dom.body          = _editor_el('body', wrapper)[0];
	dom.bodyContent   = _editor_el('body_content', wrapper)[0];
	dom.processing    = _editor_el('processing', wrapper)[0];

	// Add any fields which are given on initialisation
	if ( init.fields ) {
		this.add( init.fields );
	}

	$(document)
		.one( 'init.dt.dte', function (e, settings, json) {
			// Attempt to attach to a DataTable automatically when the table is
			// initialised
			if ( that.s.table && settings.nTable === $(that.s.table).get(0) ) {
				settings._editor = that;
			}
		} )
		.on( 'xhr.dt', function (e, settings, json) {
			// Automatically update fields which have a field name defined in
			// the returned json - saves an `initComplete` for the user
			if ( that.s.table && settings.nTable === $(that.s.table).get(0) ) {
				that._optionsUpdate( json );
			}
		} );

	// Prep the display controller
	this.s.displayController = Editor.display[init.display].init( this );

	this._event( 'initComplete', [] );
};



/**
 * Set the class on the form to relate to the action that is being performed.
 * This allows styling to be applied to the form to reflect the state that
 * it is in.
 *
 * @private
 */
Editor.prototype._actionClass = function ()
{
	var classesActions = this.classes.actions;
	var action = this.s.action;
	var wrapper = $(this.dom.wrapper);

	wrapper.removeClass( [classesActions.create, classesActions.edit, classesActions.remove].join(' ') );

	if ( action === "create" ) {
		wrapper.addClass( classesActions.create );
	}
	else if ( action === "edit" ) {
		wrapper.addClass( classesActions.edit );
	}
	else if ( action === "remove" ) {
		wrapper.addClass( classesActions.remove );
	}
};


/**
 * Create an Ajax request in the same style as DataTables 1.10, with full
 * backwards compatibility for Editor 1.2.
 *
 * @param  {object} data Data to submit
 * @param  {function} success Success callback
 * @param  {function} error Error callback
 * @private
 */
Editor.prototype._ajax = function ( data, success, error )
{
	var opts = {
		type:     'POST',
		dataType: 'json',
		data:     null,
		success:  success,
		error:    error
	};
	var a;
	var action = this.s.action;
	var ajaxSrc = this.s.ajax || this.s.ajaxUrl;
	var id = action === 'edit' || action === 'remove' ?
		this._dataSource( 'id', this.s.modifier ) :
		null;

	if ( $.isArray( id ) ) {
		id = id.join(',');
	}

	// Get the correct object for rest style
	if ( $.isPlainObject( ajaxSrc ) && ajaxSrc[ action ] ) {
		ajaxSrc = ajaxSrc[ action ];
	}

	if ( $.isFunction( ajaxSrc ) ) {
		// As a function, execute it, passing in the required parameters
		var uri = null;
		var method = null;

		// If the old style ajaxSrc is given, we need to process it for
		// backwards compatibility with 1.2-. Unfortunate otherwise this would
		// be a very simply function!
		if ( this.s.ajaxUrl ) {
			var url = this.s.ajaxUrl;

			if ( url.create ) {
				uri = url[ action ];
			}

			if ( uri.indexOf(' ') !== -1 ) {
				a = uri.split(' ');
				method = a[0];
				uri = a[1];
			}

			uri = uri.replace( /_id_/, id );
		}
		
		ajaxSrc( method, uri, data, success, error );
		return;
	}
	else if ( typeof ajaxSrc === 'string' ) {
		// As a string it gives the URL. For backwards compatibility it can also
		// give the method.
		if ( ajaxSrc.indexOf(' ') !== -1 ) {
			a = ajaxSrc.split(' ');
			opts.type = a[0];
			opts.url = a[1];
		}
		else {
			opts.url = ajaxSrc;
		}
	}
	else {
		// As an object, we extend the defaults
		opts = $.extend( {}, opts, ajaxSrc || {} );
	}

	// URL macros
	opts.url = opts.url.replace( /_id_/, id );

	// Data processing option like in DataTables
	if ( opts.data ) {
		var newData = $.isFunction( opts.data ) ?
			opts.data( data ) :  // fn can manipulate data or return an object
			opts.data;           // object or array to merge

		// If the function returned something, use that alone
		data = $.isFunction( opts.data ) && newData ?
			newData :
			$.extend( true, data, newData );
	}

	opts.data = data;

	// Finally, make the ajax call
	$.ajax( opts );
};


/**
 * Create the DOM structure from the source elements for the main form.
 * This is required since the elements can be moved around for other form types
 * (bubble).
 *
 * @private
 */
Editor.prototype._assembleMain = function ()
{
	var dom = this.dom;

	$(dom.wrapper)
		.prepend( dom.header );

	$(dom.footer)
		.append( dom.formError )
		.append( dom.buttons );

	$(dom.bodyContent)
		.append( dom.formInfo )
		.append( dom.form );
};


/**
 * Blur the editing window. A blur is different from a close in that it might
 * cause either a close or the form to be submitted. A typical example of a
 * blur would be clicking on the background of the bubble or main editing forms
 * - i.e. it might be a close, or it might submit depending upon the
 * configuration, while a click on the close box is a very definite close.
 *
 * @private
 */
Editor.prototype._blur = function ()
{
	var opts = this.s.editOpts;

	if ( ! opts.blurOnBackground ) {
		return;
	}

	if ( this._event( 'preBlur' ) === false ) {
		return;
	}

	if ( opts.submitOnBlur ) {
		this.submit();
	}
	else {
		this._close();
	}
};


/**
 * Clear all of the information that might have been dynamically set while
 * the form was visible - specifically errors and dynamic messages
 *
 * @private
 */
Editor.prototype._clearDynamicInfo = function ()
{
	var errorClass = this.classes.field.error;
	var fields = this.s.fields;

	$('div.'+errorClass, this.dom.wrapper).removeClass( errorClass );

	$.each( fields, function (name, field) {
		field
			.error('')
			.message('');
	} );

	this
		.error('')
		.message('');
};


/**
 * Close an editing display, firing callbacks and events as needed
 *
 * @param  {function} submitComplete Function to call after the preClose event
 * @private
 */
Editor.prototype._close = function ( submitComplete )
{
	// Allow preClose event to cancel the opening of the display
	if ( this._event( 'preClose' ) === false ) {
		return;
	}

	if ( this.s.closeCb ) {
		this.s.closeCb( submitComplete );
		this.s.closeCb = null;
	}

	if ( this.s.closeIcb ) {
		this.s.closeIcb();
		this.s.closeIcb = null;
	}

	// Remove focus control
	$('body').off( 'focus.editor-focus' );

	this.s.displayed = false;
	this._event( 'close' );
};


/**
 * Register a function to be called when the editing display is closed. This is
 * used by function that create the editing display to tidy up the display on
 * close - for example removing event handlers to prevent memory leaks.
 *
 * @param  {function} fn Function to call on close
 * @private
 */
Editor.prototype._closeReg = function ( fn )
{
	this.s.closeCb = fn;
};


/**
 * Argument shifting for the create(), edit() and remove() methods. In Editor
 * 1.3 the preferred form of calling those three methods is with just two
 * parameters (one in the case of create() - the id and the show flag), while in
 * previous versions four / three parameters could be passed in, including the
 * buttons and title options. In 1.3 the chaining API is preferred, but we want
 * to support the old form as well, so this function is provided to perform
 * that argument shifting, common to all three.
 *
 * @private
 */
Editor.prototype._crudArgs = function ( arg1, arg2, arg3, arg4 )
{
	var that = this;
	var title;
	var buttons;
	var show;
	var opts;

	if ( $.isPlainObject( arg1 ) ) {
		// Form options passed in as the first option
		opts = arg1;
	}
	else if ( typeof arg1 === 'boolean' ) {
		// Show / hide passed in as the first option - form options second
		show = arg1;
		opts = arg2; // can be undefined
	}
	else {
		// Old style arguments
		title = arg1; // can be undefined
		buttons = arg2; // can be undefined
		show = arg3; // can be undefined
		opts = arg4; // can be undefined
	}

	// If all undefined, then fall into here
	if ( show === undefined ) {
		show = true;
	}

	if ( title ) {
		that.title( title );
	}

	if ( buttons ) {
		that.buttons( buttons );
	}

	return {
		opts: $.extend( {}, this.s.formOptions.main, opts ),
		maybeOpen: function () {
			if ( show ) {
				that.open();
			}
		}
	};
};


/**
 * Execute the data source abstraction layer functions. This is simply a case
 * of executing the function with the Editor scope, passing in the remaining
 * parameters.
 *
 * @param {string) name Function name to execute
 * @private
 */
Editor.prototype._dataSource = function ( name /*, ... */ )
{
	// Remove the name from the arguments list, so the rest can be passed
	// straight into the field type
	var args = Array.prototype.slice.call( arguments );
	args.shift();

	var fn = this.s.dataSource[ name ];
	if ( fn ) {
		return fn.apply( this, args );
	}
};


/**
 * Insert the fields into the DOM, in the correct order
 *
 * @private
 */
Editor.prototype._displayReorder = function ( includeFields )
{
	var formContent = $(this.dom.formContent);
	var fields = this.s.fields;
	var order = includeFields || this.s.order;

	// Empty before adding in the required fields
	formContent.children().detach();

	$.each( order, function (i, fieldOrName) {
		formContent.append( fieldOrName instanceof Editor.Field ?
			fieldOrName.node() :
			fields[ fieldOrName ].node()
		);
	} );
};


/**
 * Generic editing handler. This can be called by the three editing modes (main,
 * bubble and inline) to configure Editor for a row edit, and fire the required
 * events to ensure that the editing interfaces all provide a common API.
 *
 * @param {*} row Identifier for the item to be edited
 * @param {string} type Editing type - for the initEdit event
 * @private
 */
Editor.prototype._edit = function ( row, type )
{
	var that = this;
	var fields = this.s.fields;
	var data = this._dataSource( 'get', row, fields );

	this.s.modifier = row;
	this.s.action = "edit";
	this.dom.form.style.display = 'block';

	this._actionClass();

	$.each( fields, function ( name, field ) {
		var val = field.valFromData( data );
		field.set( val !== undefined ? val : field.def() );
	} );

	this._event( 'initEdit', [
		this._dataSource( 'node', row ),
		data,
		row,
		type
	] );
};


/**
 * Fire callback functions and trigger events.
 *
 * @param {string|array} trigger Name(s) of the jQuery custom event to trigger
 * @param {array) args Array of arguments to pass to the triggered event
 * @return {*} Return from the event
 * @private
 */
Editor.prototype._event = function ( trigger, args )
{
	if ( ! args ) {
		args = [];
	}

	// Allow an array to be passed in for the trigger to fire multiple events
	if ( $.isArray( trigger ) ) {
		for ( var i=0, ien=trigger.length ; i<ien ; i++ ) {
			this._event( trigger[i], args );
		}
	}
	else {
		var e = $.Event( trigger );

		$(this).triggerHandler( e, args );

		return e.result;
	}
};


/**
 * 'Modernise' event names, from the old style `on[A-Z]` names to camelCase.
 * This is done to provide backwards compatibility with Editor 1.2- event names.
 * The names themselves were updated for consistency with DataTables.
 *
 * @param {string} Event name to modernise
 * @return {string} String with new event name structure
 * @private
 */
Editor.prototype._eventName = function ( input )
{
	var name;
	var names = input.split( ' ' );

	for ( var i=0, ien=names.length ; i<ien ; i++ ) {
		name = names[i];

		// Strip the 'on' part and lowercase the first character
		var onStyle = name.match(/^on([A-Z])/);
		if ( onStyle ) {
			name = onStyle[1].toLowerCase() + name.substring( 3 );
		}

		names[i] = name;
	}

	return names.join( ' ' );
};


/**
 * Focus on a field. Providing the logic to allow complex focus expressions
 *
 * @param {array} fields Array of Field instances that are shown
 * @param {null|string|integer} focus Field identifier to focus on
 * @private
 */
Editor.prototype._focus = function ( fields, focus )
{
	var field;

	if ( typeof focus === 'number' ) {
		field = fields[ focus ];
	}
	else if ( focus ) {
		if ( focus.indexOf( 'jq:' ) === 0 ) {
			field = $('div.DTE '+focus.replace(/^jq:/, ''));
		}
		else {
			field = this.s.fields[ focus ];
		}
	}

	this.s.setFocus = field;

	if ( field ) {
		field.focus();
	}
};


/**
 * Form options - common function so all editing methods can provide the same
 * basic options, DRY.
 *
 * @param {object} opts Editing options. See model.formOptions
 * @private
 */
Editor.prototype._formOptions = function ( opts )
{
	var that = this;
	var inlineCount = __inlineCounter++;
	var namespace = '.dteInline'+inlineCount;

	this.s.editOpts = opts;

	// When submitting by Ajax we don't want to close a form that has been
	// opened during the ajax request, so we keep a count of the form opening
	this.s.editCount = inlineCount;

	if ( typeof opts.title === 'string' ) {
		this.title( opts.title );
		opts.title = true;
	}

	if ( typeof opts.message === 'string' ) {
		this.message( opts.message );
		opts.message = true;
	}

	if ( typeof opts.buttons !== 'boolean' ) {
		this.buttons( opts.buttons );
		opts.buttons = true;
	}

	$(document).on( 'keydown'+namespace, function ( e ) {
		// not good enough - need to consider checkboxes etc
		var el = $(document.activeElement);
		var name = el.length ? el[0].nodeName.toLowerCase() : null;
		var type = $(el).attr('type');

		// Check if the return key should submit the form in the current element
		var returnFriendlyNode = name === 'input' && $.inArray(
			type,
			[
				'color', 'date', 'datetime', 'datetime-local', 'email', 'month',
				'number', 'password', 'range', 'search', 'tel', 'text', 'time',
				'url', 'week'
			]
		) !== -1;

		if ( that.s.displayed && opts.submitOnReturn && e.keyCode === 13 && returnFriendlyNode ) { // return
			e.preventDefault();
			that.submit();
		}
		else if ( e.keyCode === 27 ) { // esc
			e.preventDefault();

			switch( opts.onEsc ) {
				case 'blur':
					that.blur();
					break;

				case 'close':
					that.close();
					break;

				case 'submit':
					that.submit();
					break;

				default: // 'none' - no action
					break;
			}
		}
		else if ( el.parents('.DTE_Form_Buttons').length ) {
			if ( e.keyCode === 37 ) { // left
				el.prev( 'button' ).focus();
			}
			else if ( e.keyCode === 39 ) { // right
				el.next( 'button' ).focus();
			}
		}
	} );

	this.s.closeIcb = function () {
		$(document).off( 'keydown'+namespace );
	};

	return namespace;
};


/**
 * Update the field options from a JSON data source
 *
 * @param  {object} json JSON object from the server
 * @private
 */
Editor.prototype._optionsUpdate = function ( json )
{
	var that = this;

	if ( json.options ) {
		$.each( this.s.fields, function (name, field) {
			if ( json.options[ name ] !== undefined ) {
				that.field( name ).update( json.options[ name ] );
			}
		} );
	}
};


/**
 * Show a message in the form. This can be used for error messages or dynamic
 * messages (information display) as the structure for each is basically the
 * same. This method will take into account if the form is visible or not - if
 * so then the message is shown with an effect for the end user, otherwise
 * it is just set immediately.
 *
 * @param {element} el The field display node to use
 * @param {string} msg The message to show
 * @private
 */
Editor.prototype._message = function ( el, msg )
{
	if ( ! msg && this.s.displayed ) {
		// Clear the message with visual effect since the form is visible
		$(el).fadeOut();
	}
	else if ( ! msg ) {
		// Clear the message without visual effect
		el.style.display = "none";
	}
	else if ( this.s.displayed ) {
		// Show the message with visual effect
		$(el).html( msg ).fadeIn();
	}
	else {
		// Show the message without visual effect
		$(el).html( msg );
		el.style.display = "block";
	}
};


/**
 * Common display editing form method called by all editing methods after the
 * form has been configured and displayed. This is to ensure all fire the same
 * events.
 *
 * @param  {string} Editing type
 * @return {boolean} `true`
 * @private
 */
Editor.prototype._postopen = function ( type )
{
	var that = this;

	$(this.dom.form)
		.off( 'submit.editor-internal' )
		.on( 'submit.editor-internal', function (e) {
			e.preventDefault();
		} );

	// Focus capture - when the Editor form is shown we capture the browser's
	// focus action. Without doing this is would result in the user being able
	// to control items under the Editor display - triggering actions that
	// shouldn't be possible while the editing is shown.
	if ( type === 'main' || type === 'bubble' ) {
		$('body').on( 'focus.editor-focus', function () {
			if ( $(document.activeElement).parents('.DTE').length === 0 &&
			     $(document.activeElement).parents('.DTED').length === 0
			) {
				if ( that.s.setFocus ) {
					that.s.setFocus.focus();
				}
			}
		} );
	}

	this._event( 'open', [type] );

	return true;
};


/**
 * Common display editing form method called by all editing methods before the
 * form has been configured and displayed. This is to ensure all fire the same
 * events.
 *
 * @param  {string} Editing type
 * @return {boolean} `false` if the open is cancelled by the preOpen event,
 *   otherwise `true`
 * @private
 */
Editor.prototype._preopen = function ( type )
{
	// Allow preOpen event to cancel the opening of the display
	if ( this._event( 'preOpen', [type] ) === false ) {
		return false;
	}

	this.s.displayed = type;

	return true;
};


/**
 * Set the form into processing mode or take it out of processing mode. In
 * processing mode a processing indicator is shown and user interaction with the
 * form buttons is blocked
 *
 * @param {boolean} processing true if to go into processing mode and false if
 *   to come out of processing mode
 * @private
 */
Editor.prototype._processing = function ( processing )
{
	var wrapper = $(this.dom.wrapper);
	var procStyle = this.dom.processing.style;
	var procClass = this.classes.processing.active;

	if ( processing ) {
		procStyle.display = 'block';
		wrapper.addClass( procClass );
		$('div.DTE').addClass( procClass );
	}
	else {
		procStyle.display = 'none';
		wrapper.removeClass( procClass );
		$('div.DTE').removeClass( procClass );
	}

	this.s.processing = processing;

	this._event( 'processing', [processing] );
};


/**
 * Submit a form to the server for processing. This is the private method that is used
 * by the 'submit' API method, which should always be called in preference to calling
 * this method directly.
 *
 * @param {function} [successCallback] Callback function that is executed once the
 *   form has been successfully submitted to the server and no errors occurred.
 * @param {function} [errorCallback] Callback function that is executed if the
 *   server reports an error due to the submission (this includes a JSON formatting
 *   error should the error return invalid JSON).
 * @param {function} [formatdata] Callback function that is passed in the data
 *   that will be submitted to the server, allowing pre-formatting of the data,
 *   removal of data or adding of extra fields.
 * @param {boolean} [hide=true] When the form is successfully submitted, by default
 *   the form display will be hidden - this option allows that to be overridden.
 * @private
 */
Editor.prototype._submit = function ( successCallback, errorCallback, formatdata, hide )
{
	var that = this;
	var i, iLen, eventRet, errorNodes;
	var setBuilder =  DataTable.ext.oApi._fnSetObjectDataFn;
	var dataSource = this.s.dataSource;
	var readValues = {};
	var fields = this.s.fields;
	var action = this.s.action;
	var editCount = this.s.editCount;
	var modifier = this.s.modifier;
	var submitParams = {
		"action": this.s.action,
		"data": {}
	};

	// For backwards compatibility
	if ( this.s.dbTable ) {
		submitParams.table = this.s.dbTable;
	}

	// Gather the data that is to be submitted
	if ( action === "create" || action === "edit" ) {
		// Add and edit use the main fields array
		$.each( fields, function (name, field) {
			// Use DataTables abilities to set complex objects to set our data output
			setBuilder( field.name() )( submitParams.data, field.get() );
		} );

		// Take a copy so we can use it as the values if the server doesn't
		// return a row parameter
		$.extend( true, readValues, submitParams.data );
	}

	if ( action === "edit" || action === "remove" ) {
		// Need to submit the ids
		submitParams.id = this._dataSource( 'id', modifier );

		if ( action === "edit" && $.isArray( submitParams.id ) ) {
			submitParams.id = submitParams.id[0];
		}
	}

	// Allow the data to be submitted to the server to be preprocessed by callback
	// and event functions
	if ( formatdata ) {
		formatdata( submitParams );
	}
	if ( this._event( 'preSubmit', [submitParams, action] ) === false ) {
		this._processing( false );
		return;
	}

	// Submit to the server (or whatever method is defined in the settings)
	this._ajax(
		submitParams,
		function (json) {
			var setData;
			that._event( 'postSubmit', [json, submitParams, action] );

			if ( !json.error ) {
				json.error = "";
			}
			if ( !json.fieldErrors ) {
				json.fieldErrors = [];
			}

			if ( json.error || json.fieldErrors.length ) {
				// Global form error
				that.error( json.error );

				// Field specific errors
				$.each( json.fieldErrors, function (i, err) {
					var field = fields[ err.name ];

					field.error( err.status || "Error" );

					if ( i === 0 ) {
						// Scroll the display to the first error and focus
						$(that.dom.bodyContent, that.s.wrapper).animate( {
							"scrollTop": $(field.node()).position().top
						}, 500 );

						field.focus();
					}
				} );

				if ( errorCallback ) {
					errorCallback.call( that, json );
				}
			}
			else {
				// If the server returns a 'row' property in the JSON, then we use that as the
				// data to feed into the DataTable. Otherwise we pull in the data from the form.
				setData = json.row !== undefined ? json.row : readValues;
				that._event( 'setData', [json, setData, action] );

				if ( action === "create" ) {
					// New row was created to add it to the DT
					if ( that.s.idSrc === null && json.id ) {
						setData.DT_RowId = json.id;
					}
					else if ( json.id ) {
						setBuilder( that.s.idSrc )( setData, json.id );
					}

					that._event( 'preCreate', [json, setData] );
					that._dataSource( 'create', fields, setData );
					that._event( ['create', 'postCreate'], [json, setData] );
				}
				else if ( action === "edit" ) {
					// Row was updated, so tell the DT
					that._event( 'preEdit', [json, setData] );
					that._dataSource( 'edit', modifier, fields, setData );
					that._event( ['edit', 'postEdit'], [json, setData] );
				}
				else if ( action === "remove" ) {
					// Remove the rows given and then redraw the table
					that._event( 'preRemove', [json] );
					that._dataSource( 'remove', modifier, fields );
					that._event( ['remove', 'postRemove'], [json] );
				}

				// Submission complete
				if ( editCount === that.s.editCount ) {
					that.s.action = null;

					if ( that.s.editOpts.closeOnComplete && (hide === undefined || hide) ) {
						that._close( true );
					}
				}

				// All done - fire off the callbacks and events
				if ( successCallback ) {
					successCallback.call( that, json );
				}
				that._event( 'submitSuccess', [json, setData] );
			}

			that._processing( false );
			that._event( 'submitComplete', [json, setData] );
		},
		function (xhr, err, thrown) {
			that._event( 'postSubmit', [xhr, err, thrown, submitParams] );

			that.error( that.i18n.error.system );
			that._processing( false );

			if ( errorCallback ) {
				errorCallback.call( that, xhr, err, thrown );
			}

			that._event( ['submitError', 'submitComplete'], [xhr, err, thrown, submitParams] );
		}
	); // /ajax submit
};


/**
 * Check to see if the form needs to be tidied before a new action can be performed.
 * This includes if the from is currently processing an old action and if it
 * is inline editing.
 *
 * @param {function} fn Callback function
 * @returns {boolean} `true` if was in inline mode, `false` otherwise
 * @private
 */
Editor.prototype._tidy = function ( fn )
{
	if ( this.s.processing ) {
		// If currently processing, wait until the action is complete
		this.one( 'submitComplete', fn );

		return true;
	}
	else if ( $('div.DTE_Inline' ).length || this.display() === 'inline' ) {
		// If there is an inline edit box, it needs to be tidied
		var that = this;

		this
			.one( 'close', function () {
				// On close if processing then we need to wait for the submit
				// to complete before running the callback as submitOnBlur was
				// set to true
				if ( ! that.s.processing ) {
					fn();
				}
				else {
					// Need to wait for the submit to finish
					that.one( 'submitComplete', function () {
						// If server-side processing is being used in DataTables,
						// wait for the draw to finished
						var table = new $.fn.dataTable.Api( that.s.table );
						if ( that.s.table && table.settings()[0].oFeatures.bServerSide ) {
							table.one( 'draw', fn );
						}
						else {
							fn();
						}
					} );
				}
			} )
			.blur();

		return true;
	}

	return false;
};


/*
 * Defaults
 */


// Dev node - although this file is held in the models directory (because it
// really is a model, it is assigned to Editor.defaults for easy
// and sensible access to set the defaults for Editor.

/**
 * Initialisation options that can be given to Editor at initialisation time.
 *  @namespace
 */
Editor.defaults = {
	/**
	 * jQuery selector that can be used to identify the table you wish to apply
	 * this editor instance to.
	 *
	 * In previous versions of Editor (1.2 and earlier), this parameter was
	 * called `table`. The name has been altered in 1.3+ to simplify the
	 * initialisation. This is a backwards compatible change - if you pass in
	 * a `table` option it will be used.
	 *  @type string
	 *  @default <i>Empty string</i>
	 *
	 *  @example
	 *    $(document).ready(function() {
	 *      var editor = new $.fn.Editor( {
	 *        "ajax": "php/index.php",
	 *        "table": "#example"
	 *      } );
	 *    } );
	 */
	"table": null,

	/**
	 * The URL, or collection of URLs when using a REST interface, which will accept 
	 * the data for the create, edit and remove functions. The target script / program
	 * must accept data in the format defined by Editor and return the expected JSON as
	 * required by Editor. When given as an object, the `create`, `edit` and `remove`
	 * properties should be defined, each being the URL to send the data to for that
	 * action. When used as an object, the string `_id_` will be replaced for the edit
	 * and remove actions, allowing a URL to be dynamically created for those actions.
	 *  @type string|object
	 *  @default <i>Empty string</i>
	 *  @deprecated This option has been deprecated in favour of the `ajax` option.
	 *    It can still be used, but it is recommended that you use the `ajax` option
	 *    which provides all of the abilities of this old option and more.
	 */
	"ajaxUrl": null,

	/**
	 * Fields to initialise the form with - see {@link Editor.models.field} for
	 * a full list of the options available to each field. Note that if fields are not 
	 * added to the form at initialisation time using this option, they can be added using
	 * the {@link Editor#add} API method.
	 *  @type array
	 *  @default []
	 *
	 *  @example
	 *    $(document).ready(function() {
	 *      var editor = new $.fn.Editor( {
	 *        "ajax": "php/index.php",
	 *        "table": "#example",
	 *        "fields": [ {
	 *            "label": "User name:",
	 *            "name": "username"
	 *          }
	 *          // More fields would typically be added here!
	 *        } ]
	 *      } );
	 *    } );
	 */
	"fields": [],

	/**
	 * The display controller for the form. The form itself is just a collection of
	 * DOM elements which require a display container. This display controller allows
	 * the visual appearance of the form to be significantly altered without major
	 * alterations to the Editor code. There are two display controllers built into
	 * Editor *lightbox* and *envelope*. The value of this property will
	 * be used to access the display controller defined in {@link Editor.display}
	 * for the given name. Additional display controllers can be added by adding objects
	 * to that object, through extending the displayController model:
	 * {@link Editor.models.displayController}.
	 *  @type string
	 *  @default lightbox
	 *
	 *  @example
	 *    $(document).ready(function() {
	 *      var editor = new $.fn.Editor( {
	 *        "ajax": "php/index.php",
	 *        "table": "#example",
	 *        "display": 'envelope'
	 *      } );
	 *    } );
	 */
	"display": 'lightbox',

	/**
	 * Control how the Ajax call to update data on the server.
	 *
	 * This option matches the `dt-init ajax` option in that is can be provided
	 * in one of three different ways:
	 *
	 * * string - As a string, the value given is used as the url to target
	 *   the Ajax request to, using the default Editor Ajax options. Note that
	 *   for backwards compatibility you can use the form "METHOD URL" - for
	 *   example: `"PUT api/users"`, although it is recommended you use the
	 *   object form described below.
	 * * object - As an object, the `ajax` property has two forms:
	 *   * Used to extend and override the default Ajax options that Editor
	 *     uses. This can be very useful for adding extra data for example, or
	 *     changing the HTTP request type.
	 *   * With `create`, `edit` and `remove` properties, Editor will use the
	 *     option for the action that it is taking, which can be useful for
	 *     REST style interfaces. The value of each property can be a string,
	 *     object or function, using exactly the same options as the main `ajax`
	 *     option. All three options must be defined if this form is to be used.
	 * * function - As a function this gives complete control over the method
	 *   used to update the server (if indeed a server is being used!). For
	 *   example, you could use a different data store such as localStorage,
	 *   Firebase or route the data through a web-socket.
	 *
	 *  @example
	 *    // As a string - all actions are submitted to this URI as POST requests
	 *    $(document).ready(function() {
	 *      var editor = new $.fn.Editor( {
	 *        "ajax": 'php/index.php',
	 *        "table": "#example"
	 *      } );
	 *    } );
	 *
	 *  @example
	 *    // As an object - using GET rather than POST
	 *    $(document).ready(function() {
	 *      var editor = new $.fn.Editor( {
	 *        "ajax": {
	 *          "type": 'GET',
	 *          "url": 'php/index.php
	 *        },
	 *        "table": "#example"
	 *      } );
	 *    } );
	 *
	 *  @example
	 *    // As an object - each action is submitted to a different URI as POST requests
	 *    $(document).ready(function() {
	 *      var editor = new $.fn.Editor( {
	 *        "ajax": {
	 *          "create": "/rest/user/create",
	 *          "edit":   "/rest/user/_id_/edit",
	 *          "remove": "/rest/user/_id_/delete"
	 *        },
	 *        "table": "#example"
	 *      } );
	 *    } );
	 *
	 *  @example
	 *    // As an object - with different HTTP methods for each action
	 *    $(document).ready(function() {
	 *      var editor = new $.fn.Editor( {
	 *        "ajax": {
	 *          "create": {
	 *          	type: 'POST',
	 *          	url:  '/rest/user/create'
	 *          },
	 *          "edit": {
	 *          	type: 'PUT',
	 *          	url:  '/rest/user/edit/_id_'
	 *          },
	 *          "remove": {
	 *          	type: 'DELETE',
	 *          	url:  '/rest/user/delete'
	 *          }
	 *        },
	 *        "table": "#example"
	 *      } );
	 *    } );
	 *
	 *    // As a function - Making a custom `$.ajax` call
	 *    $(document).ready(function() {
	 *      var editor = new $.fn.Editor( {
	 *        "ajax": "php/index.php",
	 *        "table": "#example",
	 *        "ajax": function ( method, url, data, successCallback, errorCallback ) {
	 *          $.ajax( {
	 *            "type": method,
	 *            "url":  url,
	 *            "data": data,
	 *            "dataType": "json",
	 *            "success": function (json) {
	 *              successCallback( json );
	 *            },
	 *            "error": function (xhr, error, thrown) {
	 *              errorCallback( xhr, error, thrown );
	 *            }
	 *          } );
	 *        }
	 *      } );
	 *    } );
	 */
	"ajax": null,

	/**
	 * JSON property from which to read / write the row's ID property (i.e. its
	 * unique column index that identifies the row to the database). By default
	 * (`null`) Editor will use the `DT_RowId` property from the data source
	 * object (DataTable's magic property to set the DOM id for the row).
	 *
	 * If you want to read a parameter from the data source object instead of
	 * using `DT_RowId`, set this option to the property name to use.
	 *
	 * Like other data source options the `srcId` option can be given in dotted
	 * object notation to read nested objects.
	 *  @type null|string
	 *  @default null
	 *
	 *  @example
	 *    // Using a data source such as:
	 *    // { "id":12, "browser":"Chrome", ... }
	 *    $(document).ready(function() {
	 *      var editor = new $.fn.Editor( {
	 *        "ajax": "php/index.php",
	 *        "table": "#example",
	 *        "idSrc": "id"
	 *      } );
	 *    } );
	 */
	"idSrc": null,

	/**
	 * Events / callbacks - event handlers can be assigned as an individual function
	 * during initialisation using the parameters in this name space. The names, and
	 * the parameters passed to each callback match their event equivalent in the
	 * {@link Editor} object.
	 *  @namespace
	 *  @deprecated Since 1.3. Use the `on()` API method instead. Note that events
	 *    passed in do still operate as they did in 1.2- but are no longer
	 *    individually documented.
	 */
	"events": {},

	/**
	 * Internationalisation options for Editor. All client-side strings that the
	 * end user can see in the interface presented by Editor can be modified here.
	 *
	 * You may also wish to refer to the <a href="http://datatables.net/usage/i18n">
	 * DataTables internationalisation options</a> to provide a fully language 
	 * customised table interface.
	 *  @namespace
	 *
	 *  @example
	 *    // Set the 'create' button text. All other strings used are the
	 *    // default values.
	 *    var editor = new $.fn.Editor( {
	 *      "ajax": "data/source",
	 *      "table": "#example",
	 *      "i18n": {
	 *        "create": {
	 *          "button": "New user"
	 *        }
	 *      }
	 *    } );
	 *
	 *  @example
	 *    // Set the submit text for all three actions
	 *    var editor = new $.fn.Editor( {
	 *      "ajax": "data/source",
	 *      "table": "#example",
	 *      "i18n": {
	 *        "create": {
	 *          "submit": "Create new user"
	 *        },
	 *        "edit": {
	 *          "submit": "Update user"
	 *        },
	 *        "remove": {
	 *          "submit": "Remove user"
	 *        }
	 *      }
	 *    } );
	 */
	"i18n": {
		/**
		 * Strings used when working with the Editor 'create' action (creating new
		 * records).
		 *  @namespace
		 */
		"create": {
			/**
			 * TableTools button text
			 *  @type string
			 *  @default New
			 */
			"button": "New",

			/**
			 * Display container title (when showing the editor display)
			 *  @type string
			 *  @default Create new entry
			 */
			"title":  "Create new entry",

			/**
			 * Submit button text
			 *  @type string
			 *  @default Create
			 */
			"submit": "Create"
		},

		/**
		 * Strings used when working with the Editor 'edit' action (editing existing
		 * records).
		 *  @namespace
		 */
		"edit": {
			/**
			 * TableTools button text
			 *  @type string
			 *  @default Edit
			 */
			"button": "Edit",

			/**
			 * Display container title (when showing the editor display)
			 *  @type string
			 *  @default Edit entry
			 */
			"title":  "Edit entry",

			/**
			 * Submit button text
			 *  @type string
			 *  @default Update
			 */
			"submit": "Update"
		},

		/**
		 * Strings used when working with the Editor 'delete' action (deleting 
		 * existing records).
		 *  @namespace
		 */
		"remove": {
			/**
			 * TableTools button text
			 *  @type string
			 *  @default Delete
			 */
			"button": "Delete",

			/**
			 * Display container title (when showing the editor display)
			 *  @type string
			 *  @default Delete
			 */
			"title":  "Delete",

			/**
			 * Submit button text
			 *  @type string
			 *  @default Delete
			 */
			"submit": "Delete",

			/**
			 * Deletion confirmation message.
			 *
			 * As Editor has the ability to delete either a single or multiple rows
			 * at a time, this option can be given as either a string (which will be
			 * used regardless of how many records are selected) or as an object 
			 * where the property "_" will be used (with %d substituted for the number
			 * of records to be deleted) as the delete message, unless there is a
			 * key with the number of records to be deleted. This allows Editor
			 * to consider the different pluralisation characteristics of different
			 * languages.
			 *  @type object|string
			 *  @default Are you sure you wish to delete %d rows?
			 *
			 *  @example
			 *    // String - no plural consideration
			 *    var editor = new $.fn.Editor( {
			 *      "ajax": "data/source",
			 *      "table": "#example",
			 *      "i18n": {
			 *        "remove": {
			 *          "confirm": "Are you sure you wish to delete %d record(s)?"
			 *        }
			 *      }
			 *    } );
			 *
			 *  @example
			 *    // Basic 1 (singular) or _ (plural)
			 *    var editor = new $.fn.Editor( {
			 *      "ajax": "data/source",
			 *      "table": "#example",
			 *      "i18n": {
			 *        "remove": {
			 *          "confirm": {
			 *            "_": "Confirm deletion of %d records.",
			 *            "1": "Confirm deletion of record."
			 *        }
			 *      }
			 *    } );
			 *
			 *  @example
			 *    // Singular, dual and plural
			 *    var editor = new $.fn.Editor( {
			 *      "ajax": "data/source",
			 *      "table": "#example",
			 *      "i18n": {
			 *        "remove": {
			 *          "confirm": {
			 *            "_": "Confirm deletion of %d records.",
			 *            "1": "Confirm deletion of record.",
			 *            "2": "Confirm deletion of both record."
			 *        }
			 *      }
			 *    } );
			 *        
			 */
			"confirm": {
				"_": "Are you sure you wish to delete %d rows?",
				"1": "Are you sure you wish to delete 1 row?"
			}
		},

		/**
		 * Strings used for error conditions.
		 *  @namespace
		 */
		"error": {
			/**
			 * Generic server error message
			 *  @type string
			 *  @default A system error has occurred (<a target=\"_blank\" href=\"//datatables.net/tn/12\">More information</a>)
			 */
			"system": "A system error has occurred (<a target=\"_blank\" href=\"//datatables.net/tn/12\">More information</a>)."
		}
	},


	formOptions: {
		bubble: $.extend( {}, Editor.models.formOptions, {
			title: false,
			message: false,
			buttons: '_basic'
		} ),

		inline: $.extend( {}, Editor.models.formOptions, {
			buttons: false
		} ),

		main: $.extend( {}, Editor.models.formOptions )
	}
};


/*
 * Extensions
 */

(function(){


var __dataSources = Editor.dataSources = {};


/* -  -  -  -  -  -  -  -  -  -
 * DataTables editor interface
 */

var __dtIsSsp = function ( dt ) {
	return dt.settings()[0].oFeatures.bServerSide;
};

var __dtApi = function ( table ) {
	return $(table).DataTable();
};

var __dtHighlight = function ( node ) {
	// Highlight a row using CSS transitions. The timeouts need to match the
	// transition duration from the CSS
	node = $(node);

	setTimeout( function () {
		node.addClass( 'highlight' );

		setTimeout( function () {
			node
				.addClass( 'noHighlight' )
				.removeClass( 'highlight' );

			setTimeout( function () {
				node.removeClass( 'noHighlight' );
			}, 550 );
		}, 500 );
	}, 20 );
};

/**
 * Get the unique ID for a row from the DOM or a JSON property
 *  @private
 */
var __dtRowId = function ( table, row, idSrc )
{
	if ( row && row.length !== undefined && typeof row !== 'function' ) {
		return $.map( row, function ( r, i ) {
			return __dtRowId( table, r, idSrc );
		} );
	}

	var rowApi = __dtApi( table ).row( row );

	// Use the row's id
	if ( idSrc === null ) {
		var d = rowApi.data();
		return d.DT_RowId !== undefined ?
			d.DT_RowId :
			rowApi.node().id;
	}

	// Get the data from the source
	var getFn = DataTable.ext.oApi._fnGetObjectDataFn( idSrc );
	return getFn( rowApi.data() );
};

__dataSources.dataTable = {
	id: function ( identifer ) {
		return __dtRowId( this.s.table, identifer, this.s.idSrc );
	},

	get: function ( identifer, fields ) {
		var d = __dtApi( this.s.table ).rows( identifer ).data().toArray();
		return $.isArray( identifer ) ? d : d[0];
	},

	node: function ( identifer, fields ) {
		var d = __dtApi( this.s.table ).rows( identifer ).nodes().toArray();
		return $.isArray( identifer ) ? d : d[0];
	},

	individual: function ( identifer, fieldName, fields ) {
		var dt = __dtApi( this.s.table );
		var field, node, idx;

		if ( $(identifer).hasClass( 'dtr-data' ) ) {
			// Responsive field
			idx = dt.responsive.index( $(identifer).closest('li') );
			node = identifer;
		}
		else {
			// DataTables cell
			var cell = dt.cell( identifer );
			
			idx = cell.index();
			node = cell.node();
		}

		if ( fields ) {
			if ( fieldName ) {
				// Manual
				field = fields[ fieldName ];
			}
			else {
				// Auto - Find a field that has a data source that matches this
				// column
				var col = dt.settings()[0].aoColumns[ idx.column ];
				var dataSrc = col.editField !== undefined ?
					col.editField :
					col.mData;

				$.each( fields, function ( name, fieldInst ) {
					if ( fieldInst.dataSrc() === dataSrc ) {
						field = fieldInst;
					}
				} );
			}

			if ( ! field ) {
				throw 'Unable to automatically determine field from source. Please specify the field name';
			}
		}

		return {
			node: node,
			edit: idx.row,
			field: field
		};
	},

	create: function ( fields, data ) {
		var dt = __dtApi( this.s.table );

		if ( __dtIsSsp( dt ) ) {
			dt.draw();
		}
		else if ( data !== null ) {
			// If the server returns null for the data, the row should be
			// displayed, perhaps due to a `where` filter
			var row = dt.row.add( data );
			dt.draw();
			__dtHighlight( row.node() );
		}
	},

	edit: function ( identifer, fields, data ) {
		var dt = __dtApi( this.s.table );

		if ( __dtIsSsp( dt ) ) {
			dt.draw( false );
		}
		else {
			// If the server returns null, then the row has been removed from
			// the current data set (possibly due to a `where` filter. If that
			// is the case, then we want to remove it from the client-side,
			// otherwise it is a simple update
			var row = dt.row( identifer );
			if ( data === null ) {
				row.remove().draw( false );
			}
			else {
				row.data( data ).draw( false );
				__dtHighlight( row.node() );
			}
		}
	},

	remove: function ( identifer, fields ) {
		var dt = __dtApi( this.s.table );

		if ( __dtIsSsp( dt ) ) {
			dt.draw();
		}
		else {
			dt.rows( identifer ).remove().draw();
		}
	}
};



/* -  -  -  -  -  -  -  -
 * HTML editor interface
 */

function __html_set( identifer, fields, data ) {
	$.each( fields, function ( name, field ) {
		__html_el( identifer, field.dataSrc() )
			.each( function () {
				// This is very frustrating, but in IE if you just write directly
				// to innerHTML, and elements that are overwritten are GC'ed,
				// even if there is a reference to them elsewhere
				while ( this.childNodes.length ) {
					this.removeChild( this.firstChild );
				}
			} )
			.html(
				field.valFromData( data )
			);
	} );
}

function __html_el ( identifer, name ) {
	var idSpecific = identifer ?
		$('[data-editor-id="'+identifer+'"]').find('[data-editor-field="'+name+'"]') :
		[];

	return idSpecific.length ?
		idSpecific :
		$('[data-editor-field="'+name+'"]');
}

__dataSources.html = {
	id: function ( identifer, fields ) {
		return identifer;
	},

	initField: function ( cfg ) {
		// THis is before the field has been initialised so can't use it API
		var label = $('[data-editor-label="'+(cfg.data || cfg.name)+'"]');
		if ( ! cfg.label && label.length ) {
			cfg.label = label.html();
		}
	},

	get: function ( identifer, fields ) {
		var out = {};

		$.each( fields, function ( name, field ) {
			var val = __html_el( identifer, field.dataSrc() ).html();

			// If no HTML element is present, jQuery returns null. We want undefined
			field.valToData( out, val === null ? undefined : val );
		} );

		return out;
	},

	node: function () {
		return document;
	},

	individual: function ( identifer, fieldName, fields ) {
		var node, editId;

		if ( typeof identifer == 'string' && fieldName === null ) {
			// Single field only = If the fieldName is null and the identifier
			// is a string, then a single field is being selected - there can be
			// no collection since there isn't enough information to identify
			// the collection
			fieldName = identifer;
			node      = __html_el( null, fieldName )[0];
			editId    = null;
		}
		else if ( typeof identifer == 'string' ) {
			// identifier is the id - field name has to be given so we know
			// which field to edit
			node   = __html_el( identifer, fieldName )[0];
			editId = identifer;
		}
		else {
			// Identifier is a node for an individual field. The field name
			// might be given, or be obtained from the DOM. An id might also be
			// obtained from the DOM if it exists.
			fieldName = fieldName || $(identifer).attr('data-editor-field');
			editId    = $(identifer).parents('[data-editor-id]').data('editor-id');
			node      = identifer;
		}

		return {
			node: node,
			edit: editId,
			field: fields ? fields[ fieldName ] : null
		};
	},

	create: function ( fields, data ) {
		// If there is an element with the id that has been created, then use it
		// to assignt he values
		if ( data ) {
			var id = data[ this.s.idSrc ];

			if ( $('[data-editor-id="'+id+'"]').length ) {
				__html_set( data[ this.s.idSrc ], fields, data );
			}
		}
	},

	edit: function ( identifer, fields, data ) {
		// On edit we want to consider both the case where we are using a
		// collection and not - the __html_set method handles this for us
		__html_set( identifer, fields, data );
	},

	remove: function ( identifer, fields ) {
		// If there is an element with an ID property matching the identifier,
		// remove it
		$('[data-editor-id="'+identifer+'"]').remove();
	}
};


/* -  -  -  -  -  -  -
 * JS editor interface
 */

__dataSources.js = {
	id: function ( identifer, fields ) {
		return identifer;
	},

	get: function ( identifer, fields ) {
		// This is slightly convoluted, but we build a data object based
		// on the values so the Editor.edit function can read back from
		// the expected data source object
		var out = {};

		$.each( fields, function ( name, field ) {
			field.valToData( out, field.val() );
		} );

		return out;
	},

	node: function () {
		return document;
	}

	// No create, edit or remove functions - use the `create`, `edit`
	// and `remove` event handlers
};


}());



/**
 * Class names that are used by Editor for its various display components.
 * A copy of this object is taken when an Editor instance is initialised, thus
 * allowing different classes to be used in different instances if required.
 * Class name changes can be useful for easy integration with CSS frameworks,
 * for example Twitter Bootstrap.
 *  @namespace
 */
Editor.classes = {
	/**
	 * Applied to the base DIV element that contains all other Editor elements
	 */
	"wrapper": "DTE",

	/**
	 * Processing classes
	 *  @namespace
	 */
	"processing": {
		/**
		 * Processing indicator element
		 */
		"indicator": "DTE_Processing_Indicator",

		/**
		 * Added to the base element ("wrapper") when the form is "processing"
		 */
		"active": "DTE_Processing"
	},

	/**
	 * Display header classes
	 *  @namespace
	 */
	"header": {
		/**
		 * Container for the header elements
		 */
		"wrapper": "DTE_Header",

		/**
		 * Liner for the header content
		 */
		"content": "DTE_Header_Content"
	},

	/**
	 * Display body classes
	 *  @namespace
	 */
	"body": {
		/**
		 * Container for the body elements
		 */
		"wrapper": "DTE_Body",

		/**
		 * Liner for the body content
		 */
		"content": "DTE_Body_Content"
	},

	/**
	 * Display footer classes
	 *  @namespace
	 */
	"footer": {
		/**
		 * Container for the footer elements
		 */
		"wrapper": "DTE_Footer",
		
		/**
		 * Liner for the footer content
		 */
		"content": "DTE_Footer_Content"
	},

	/**
	 * Form classes
	 *  @namespace
	 */
	"form": {
		/**
		 * Container for the form elements
		 */
		"wrapper": "DTE_Form",

		/**
		 * Liner for the form content
		 */
		"content": "DTE_Form_Content",

		/**
		 * Applied to the <form> tag
		 */
		"tag":     "",

		/**
		 * Global form information
		 */
		"info":    "DTE_Form_Info",

		/**
		 * Global error imformation
		 */
		"error":   "DTE_Form_Error",

		/**
		 * Buttons container
		 */
		"buttons": "DTE_Form_Buttons",

		/**
		 * Buttons container
		 */
		"button": "btn"
	},

	/**
	 * Field classes
	 *  @namespace
	 */
	"field": {
		/**
		 * Container for each field
		 */
		"wrapper":     "DTE_Field",

		/**
		 * Class prefix for the field type - field type is added to the end allowing
		 * styling based on field type.
		 */
		"typePrefix":  "DTE_Field_Type_",

		/**
		 * Class prefix for the field name - field name is added to the end allowing
		 * styling based on field name.
		 */
		"namePrefix":  "DTE_Field_Name_",

		/**
		 * Field label
		 */
		"label":       "DTE_Label",

		/**
		 * Field input container
		 */
		"input":       "DTE_Field_Input",

		/**
		 * Field error state (added to the field.wrapper element when in error state
		 */
		"error":       "DTE_Field_StateError",

		/**
		 * Label information text
		 */
		"msg-label":   "DTE_Label_Info",

		/**
		 * Error information text
		 */
		"msg-error":   "DTE_Field_Error",

		/**
		 * Live messaging (API) information text
		 */
		"msg-message": "DTE_Field_Message",

		/**
		 * General information text
		 */
		"msg-info":    "DTE_Field_Info"
	},

	/**
	 * Action classes - these are added to the Editor base element ("wrapper")
	 * and allows styling based on the type of form view that is being employed.
	 *  @namespace
	 */
	"actions": {
		/**
		 * Editor is in 'create' state
		 */
		"create": "DTE_Action_Create",

		/**
		 * Editor is in 'edit' state
		 */
		"edit":   "DTE_Action_Edit",

		/**
		 * Editor is in 'remove' state
		 */
		"remove": "DTE_Action_Remove"
	},

	/**
	 * Bubble editing classes - these are used to display the bubble editor
	 *  @namespace
	 */
	"bubble": {
		/**
		 * Bubble container element
		 */
		"wrapper": "DTE DTE_Bubble",

		/**
		 * Bubble content liner
		 */
		"liner": "DTE_Bubble_Liner",

		/**
		 * Bubble table display wrapper, so the buttons and form can be shown
		 * as table cells (via css)
		 */
		"table": "DTE_Bubble_Table",

		/**
		 * Close button
		 */
		"close": "DTE_Bubble_Close",

		/**
		 * Pointer shown which node is being edited
		 */
		"pointer": "DTE_Bubble_Triangle",

		/**
		 * Fixed background
		 */
		"bg": "DTE_Bubble_Background"
	}
};



/*
 * Add helpful TableTool buttons to make life easier
 *
 * Note that the values that require a string to make any sense (the button text
 * for example) are set by Editor when Editor is initialised through the i18n
 * options.
 */
if ( $.fn.dataTable.TableTools ) {
	var ttButtons = $.fn.dataTable.TableTools.BUTTONS;

	ttButtons.editor_create = $.extend( true, ttButtons.text, {
		"sButtonText": null,
		"editor":      null,
		"formTitle":   null,
		"formButtons": [
			{ "label": null, "fn": function (e) { this.submit(); } }
		],
		"fnClick": function( button, config ) {
			var editor = config.editor;
			var i18nCreate = editor.i18n.create;
			var buttons = config.formButtons;

			if ( ! buttons[0].label ) {
				buttons[0].label = i18nCreate.submit;
			}

			editor.create( {
				title: i18nCreate.title,
				buttons: buttons
			} );
		}
	} );


	ttButtons.editor_edit = $.extend( true, ttButtons.select_single, {
		"sButtonText": null,
		"editor":      null,
		"formTitle":   null,
		"formButtons": [
			{ "label": null, "fn": function (e) { this.submit(); } }
		],
		"fnClick": function( button, config ) {
			var selected = this.fnGetSelectedIndexes();
			if ( selected.length !== 1 ) {
				return;
			}

			var editor = config.editor;
			var i18nEdit = editor.i18n.edit;
			var buttons = config.formButtons;

			if ( ! buttons[0].label ) {
				buttons[0].label = i18nEdit.submit;
			}

			editor.edit( selected[0], {
				title: i18nEdit.title,
				buttons: buttons
			} );
		}
	} );


	ttButtons.editor_remove = $.extend( true, ttButtons.select, {
		"sButtonText": null,
		"editor":      null,
		"formTitle":   null,
		"formButtons": [
			{
				"label": null,
				"fn": function (e) {
					// Executed in the Form instance's scope
					var that = this;
					this.submit( function ( json ) {
						var tt = $.fn.dataTable.TableTools.fnGetInstance(
							$(that.s.table).DataTable().table().node()
						);
						tt.fnSelectNone();
					} );
				}
			}
		],
		"question": null,
		"fnClick": function( button, config ) {
			var rows = this.fnGetSelectedIndexes();
			if ( rows.length === 0 ) {
				return;
			}

			var editor = config.editor;
			var i18nRemove = editor.i18n.remove;
			var buttons = config.formButtons;
			var question = i18nRemove.confirm === 'string' ?
				i18nRemove.confirm :
				i18nRemove.confirm[rows.length] ?
					i18nRemove.confirm[rows.length] : i18nRemove.confirm._;

			if ( ! buttons[0].label ) {
				buttons[0].label = i18nRemove.submit;
			}

			editor.remove( rows, {
				message: question.replace( /%d/g, rows.length ),
				title: i18nRemove.title,
				buttons: buttons
			} );
		}
	} );
}


/**
 * Field types array - this can be used to add field types or modify the pre-defined options.
 * By default Editor provides the following field tables (these can be readily modified,
 * extended or added to using field type plug-ins if you wish to create a custom input
 * control):
 *
 *  * `hidden` - A hidden field which cannot be seen or modified by the user
 *  * `readonly` - Input where the value cannot be modified
 *  * `text` - Text input
 *  * `password` - Text input but bulleted out text
 *  * `textarea` - Textarea input for larger text inputs
 *  * `select` - Single select list
 *  * `checkbox` - Checkboxs
 *  * `radio` - Radio buttons
 *  * `date` - Date input control (requires jQuery UI's datepicker)
 *
 *  @namespace
 */
Editor.fieldTypes = {};


(function() {

var fieldTypes = Editor.fieldTypes;

// A number of the fields in this file use the same get, set, enable and disable
// methods (specifically the text based controls), so in order to reduce the code
// size, we just define them once here in our own local base model for the field
// types.
var baseFieldType = $.extend( true, {}, Editor.models.fieldType, {
	"get": function ( conf ) {
		return conf._input.val();
	},

	"set": function ( conf, val ) {
		conf._input.val( val ).trigger( 'change' );
	},

	"enable": function ( conf ) {
		conf._input.prop( 'disabled', false );
	},

	"disable": function ( conf ) {
		conf._input.prop( 'disabled', true );
	}
} );



fieldTypes.hidden = $.extend( true, {}, baseFieldType, {
	"create": function ( conf ) {
		conf._val = conf.value;
		return null;
	},

	"get": function ( conf ) {
		return conf._val;
	},

	"set": function ( conf, val ) {
		conf._val = val;
	}
} );


fieldTypes.readonly = $.extend( true, {}, baseFieldType, {
	"create": function ( conf ) {
		conf._input = $('<input/>').attr( $.extend( {
			id: Editor.safeId( conf.id ),
			type: 'text',
			readonly: 'readonly'
		}, conf.attr || {} ) );

		return conf._input[0];
	}
} );


fieldTypes.text = $.extend( true, {}, baseFieldType, {
	"create": function ( conf ) {
		conf._input = $('<input/>').attr( $.extend( {
			id: Editor.safeId( conf.id ),
			type: 'text'
		}, conf.attr || {} ) );

		return conf._input[0];
	}
} );


fieldTypes.password = $.extend( true, {}, baseFieldType, {
	"create": function ( conf ) {
		conf._input = $('<input/>').attr( $.extend( {
			id: Editor.safeId( conf.id ),
			type: 'password'
		}, conf.attr || {} ) );

		return conf._input[0];
	}
} );

fieldTypes.textarea = $.extend( true, {}, baseFieldType, {
	"create": function ( conf ) {
		conf._input = $('<textarea/>').attr( $.extend( {
			id: Editor.safeId( conf.id )
		}, conf.attr || {} ) );
		return conf._input[0];
	}
} );


fieldTypes.select = $.extend( true, {}, baseFieldType, {
	// Locally "private" function that can be reused for the create and update methods
	"_addOptions": function ( conf, opts ) {
		var elOpts = conf._input[0].options;

		elOpts.length = 0;

		if ( opts ) {
			Editor.pairs( opts, conf.optionsPair, function ( val, label, i ) {
				elOpts[i] = new Option( label, val );
			} );
		}
	},

	"create": function ( conf ) {
		conf._input = $('<select/>').attr( $.extend( {
			id: Editor.safeId( conf.id )
		}, conf.attr || {} ) );

		fieldTypes.select._addOptions( conf, conf.options || conf.ipOpts );

		return conf._input[0];
	},

	"update": function ( conf, options ) {
		// Get the current value
		var select = $(conf._input);
		var currVal = select.val();

		fieldTypes.select._addOptions( conf, options );

		// Set the old value, if it exists
		if ( select.children('[value="'+currVal+'"]').length ) {
			select.val( currVal );
		}
	}
} );


fieldTypes.checkbox = $.extend( true, {}, baseFieldType, {
	// Locally "private" function that can be reused for the create and update methods
	"_addOptions": function ( conf, opts ) {
		var val, label;
		var elOpts = conf._input[0].options;
		var jqInput = conf._input.empty();

		if ( opts ) {
			Editor.pairs( opts, conf.optionsPair, function ( val, label, i ) {
				jqInput.append(
					'<div>'+
						'<input id="'+Editor.safeId( conf.id )+'_'+i+'" type="checkbox" value="'+val+'" />'+
						'<label for="'+Editor.safeId( conf.id )+'_'+i+'">'+label+'</label>'+
					'</div>'
				);
			} );
		}
	},


	"create": function ( conf ) {
		conf._input = $('<div />');
		fieldTypes.checkbox._addOptions( conf, conf.options || conf.ipOpts );

		return conf._input[0];
	},

	"get": function ( conf ) {
		var out = [];
		conf._input.find('input:checked').each( function () {
			out.push( this.value );
		} );
		return conf.separator ? out.join(conf.separator) : out;
	},

	"set": function ( conf, val ) {
		var jqInputs = conf._input.find('input');
		if ( ! $.isArray(val) && typeof val === 'string' ) {
			val = val.split( conf.separator || '|' );
		}
		else if ( ! $.isArray(val) ) {
			val = [ val ];
		}

		var i, len=val.length, found;

		jqInputs.each( function () {
			found = false;

			for ( i=0 ; i<len ; i++ ) {
				if ( this.value == val[i] ) {
					found = true;
					break;
				}
			}

			this.checked = found;
		} ).change();
	},

	"enable": function ( conf ) {
		conf._input.find('input').prop('disabled', false);
	},

	"disable": function ( conf ) {
		conf._input.find('input').prop('disabled', true);
	},

	"update": function ( conf, options ) {
		// Get the current value
		var checkbox = fieldTypes.checkbox;
		var currVal = checkbox.get( conf );

		checkbox._addOptions( conf, options );
		checkbox.set( conf, currVal );
	}
} );


fieldTypes.radio = $.extend( true, {}, baseFieldType, {
	// Locally "private" function that can be reused for the create and update methods
	"_addOptions": function ( conf, opts ) {
		var val, label;
		var elOpts = conf._input[0].options;
		var jqInput = conf._input.empty();

		if ( opts ) {
			Editor.pairs( opts, conf.optionsPair, function ( val, label, i ) {
				jqInput.append(
					'<div>'+
						'<input id="'+Editor.safeId( conf.id )+'_'+i+'" type="radio" name="'+conf.name+'" />'+
						'<label for="'+Editor.safeId( conf.id )+'_'+i+'">'+label+'</label>'+
					'</div>'
				);
				$('input:last', jqInput).attr('value', val)[0]._editor_val = val;
			} );
		}
	},


	"create": function ( conf ) {
		conf._input = $('<div />');
		fieldTypes.radio._addOptions( conf, conf.options || conf.ipOpts );

		// this is ugly, but IE6/7 has a problem with radio elements that are created
		// and checked before being added to the DOM! Basically it doesn't check them. As
		// such we use the _preChecked property to set cache the checked button and then
		// check it again when the display is shown. This has no effect on other browsers
		// other than to cook a few clock cycles.
		this.on('open', function () {
			conf._input.find('input').each( function () {
				if ( this._preChecked ) {
					this.checked = true;
				}
			} );
		} );

		return conf._input[0];
	},

	"get": function ( conf ) {
		var el = conf._input.find('input:checked');
		return el.length ? el[0]._editor_val : undefined;
	},

	"set": function ( conf, val ) {
		var that  = this;

		conf._input.find('input').each( function () {
			this._preChecked = false;

			if ( this._editor_val == val ) {
				this.checked = true;
				this._preChecked = true;
			}
			else {
				// In a detached DOM tree, there is no relationship between the
				// input elements, so we need to uncheck any element that does
				// not match the value
				this.checked = false;
				this._preChecked = false;
			}
		} );

		conf._input.find('input:checked').change();
	},

	"enable": function ( conf ) {
		conf._input.find('input').prop('disabled', false);
	},

	"disable": function ( conf ) {
		conf._input.find('input').prop('disabled', true);
	},

	"update": function ( conf, options ) {
		var radio = fieldTypes.radio;
		var currVal = radio.get( conf );

		radio._addOptions( conf, options );

		// Select the current value if it exists in the new data set, otherwise
		// select the first radio input so there is always a value selected
		var inputs = conf._input.find('input');
		radio.set( conf, inputs.filter('[value="'+currVal+'"]').length ?
			currVal :
			inputs.eq(0).attr('value')
		);
	}
} );


fieldTypes.date = $.extend( true, {}, baseFieldType, {
	"create": function ( conf ) {
		if ( ! $.datepicker ) { // HTML5
			conf._input = $('<input/>').attr( $.extend( {
				id: Editor.safeId( conf.id ),
				type: 'date'
			}, conf.attr || {} ) );

			return conf._input[0];
		}

		// jQuery UI
		conf._input = $('<input />').attr( $.extend( {
			type: 'text',
			id: Editor.safeId( conf.id ),
			'class': 'jqueryui'
		}, conf.attr || {} ) );

		if ( ! conf.dateFormat ) {
			conf.dateFormat = $.datepicker.RFC_2822;
		}

		if ( conf.dateImage === undefined ) {
			conf.dateImage = "../../images/calender.png";
		}

		// Allow the element to be attached to the DOM
		setTimeout( function () {
			$( conf._input ).datepicker( $.extend( {
				showOn: "both",
				dateFormat: conf.dateFormat,
				buttonImage: conf.dateImage,
				buttonImageOnly: true
			}, conf.opts ) );
			$('#ui-datepicker-div').css('display','none');
		}, 10 );

		return conf._input[0];
	},

	// use default get method as will work for both

	"set": function ( conf, val ) {
		if ( $.datepicker && conf._input.hasClass('hasDatepicker') ) {
			// Due to the async init of the control it is possible that we might
			// try to set a value before it has been initialised!
			conf._input.datepicker( "setDate" , val ).change();
		}
		else {
			$(conf._input).val( val );
		}
	},

	"enable": function ( conf ) {
		$.datepicker ?
			conf._input.datepicker( "enable" ) :
			$(conf._input).prop( 'disabled', false );
	},

	"disable": function ( conf ) {
		$.datepicker ?
			conf._input.datepicker( "disable" ) :
			$(conf._input).prop( 'disabled', true );
	},

	owns: function ( conf, node ) {
		return $(node).parents('div.ui-datepicker').length || $(node).parents('div.ui-datepicker-header').length ?
			true :
			false;
	}
} );

}());



/**
 * Name of this class
 *  @constant CLASS
 *  @type     String
 *  @default  Editor
 */
Editor.prototype.CLASS = "Editor";


/**
 * DataTables Editor version
 *  @constant  Editor.VERSION
 *  @type      String
 *  @default   See code
 *  @static
 */
Editor.version = "1.4.2";


// Event documentation for JSDoc
/**
 * Processing event, fired when Editor submits data to the server for processing.
 * This can be used to provide your own processing indicator if your UI framework
 * already has one.
 *  @name Editor#processing
 *  @event
 *  @param {event} e jQuery event object
 *  @param {boolean} processing Flag for if the processing is running (true) or
 *    not (false).
 */

/**
 * Form displayed event, fired when the form is made available in the DOM. This
 * can be useful for fields that require height and width calculations to be
 * performed since the element is not available in the document until the
 * form is displayed.
 *  @name Editor#open
 *  @event
 *  @param {event} e jQuery event object
 *  @param {string} type Editing type
 */

/**
 * Before a form is displayed, this event is fired. It allows the open action to be
 * cancelled by returning false from the function.
 *  @name Editor#preOpen
 *  @event
 *  @param {event} e jQuery event object
 */

/**
 * Form hidden event, fired when the form is removed from the document. The
 * of the compliment `open` event.
 *  @name Editor#close
 *  @event
 *  @param {event} e jQuery event object
 */

/**
 * Before a form is closed, this event is fired. It allows the close action to be
 * cancelled by returning false from the function. This can be useful for confirming
 * that the user actually wants to close the display (if they have unsaved changes
 * for example).
 *  @name Editor#preClose
 *  @event
 *  @param {event} e jQuery event object
 *  @param {string} trigger Action that caused the close event - can be undefined.
 *    Typically defined by the display controller.
 */

/**
 * Emitted before a form blur occurs. A form blur is similar to a close, but
 * is triggered by a user, typically, clicking on the background, while a close
 * occurs due to a click on the close button. A blur can precede a close.
 *  @name Editor#preBlur
 *  @event
 *  @param {event} e jQuery event object
 */

/**
 * Pre-submit event for the form, fired just before the data is submitted to
 * the server. This event allows you to modify the data that will be submitted
 * to the server. Note that this event runs after the 'formatdata' callback
 * function of the {@link Editor#submit} API method.
 *  @name Editor#preSubmit
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} data The data object that will be submitted to the server
 *  @param {string} action The action type for this submit - `create`, `edit` or
 *    `remove`.
 */

/**
 * Post-submit event for the form, fired immediately after the data has been
 * loaded by the Ajax call, allowing modification or any other interception
 * of the data returned form the server.
 *  @name Editor#postSubmit
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 *  @param {object} data The data object that was be submitted to the server
 *  @param {string} action The action type for this submit - `create`, `edit` or
 *    `remove`.
 */

/**
 * Submission complete event, fired when data has been submitted to the server and
 * after any of the return handling code has been run (updating the DataTable
 * for example). Note that unlike `submitSuccess` and `submitError`, `submitComplete`
 * will be fired for both a successful submission and an error. Additionally this
 * event will be fired after `submitSuccess` or `submitError`.
 *  @name Editor#submitComplete
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 *  @param {object} data The data that was used to update the DataTable
 */

/**
 * Submission complete and successful event, fired when data has been successfully
 * submitted to the server and all actions required by the returned data (inserting
 * or updating a row) have been completed.
 *  @name Editor#submitSuccess
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 *  @param {object} data The data that was used to update the DataTable
 */

/**
 * Submission complete, but in error event, fired when data has been submitted to
 * the server but an error occurred on the server (typically a JSON formatting error)
 *  @name Editor#submitError
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} xhr The Ajax object
 *  @param {string} err The error message from jQuery
 *  @param {object} thrown The exception thrown by jQuery
 *  @param {object} data The data that was used to update the DataTable
 */

/**
 * Create method activated event, fired when the create API method has been called,
 * just prior to the form being shown. Useful for manipulating the form specifically
 * for the create state.
 *  @name Editor#initCreate
 *  @event
 *  @param {event} e jQuery event object
 */

/**
 * Pre-create new row event, fired just before DataTables calls the fnAddData method
 * to add new data to the DataTable, allowing modification of the data that will be
 * used to insert into the table.
 *  @name Editor#preCreate
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 *  @param {object} data The data that will be used to update the DataTable
 */

/**
 * Create new row event, fired when a new row has been created in the DataTable by
 * a form submission. This is called just after the fnAddData call to the DataTable.
 *  @name Editor#create
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 *  @param {object} data The data that was used to update the DataTable
 */

/**
 * As per the `create` event - included for naming consistency.
 *  @name Editor#postCreate
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 *  @param {object} data The data that was used to update the DataTable
 */

/**
 * Edit method activated event, fired when the edit API method has been called,
 * just prior to the form being shown. Useful for manipulating the form specifically
 * for the edit state.
 *  @name Editor#initEdit
 *  @event
 *  @param {event} e jQuery event object
 *  @param {node} tr TR element of the row to be edited
 *  @param {array|object} data Data source array / object for the row to be
 *    edited
 */

/**
 * Pre-edit row event, fired just before DataTables calls the fnUpdate method
 * to edit data in a DataTables row, allowing modification of the data that will be
 * used to update the table.
 *  @name Editor#preEdit
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 *  @param {object} data The data that will be used to update the DataTable
 */

/**
 * Edit row event, fired when a row has been edited in the DataTable by a form
 * submission. This is called just after the fnUpdate call to the DataTable.
 *  @name Editor#edit
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 *  @param {object} data The data that was used to update the DataTable
 */

/**
 * As per the `edit` event - included for naming consistency.
 *  @name Editor#postEdit
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 *  @param {object} data The data that was used to update the DataTable
 */

/**
 * Remove method activated event, fired when the remove API method has been
 * called, just prior to the form being shown. Useful for manipulating the form
 * specifically for the remove state.
 *  @name Editor#initRemove
 *  @event
 *  @param {event} e jQuery event object
 *  @param {array} trs Array of the TR elements for the removed to be deleted
 *  @param {array} data Array of the data source array / objects for the rows to
 *    be deleted. This is in the same index order as the TR nodes in the second
 *    parameter.
 */

/**
 * Pre-remove row event, fired just before DataTables calls the fnDeleteRow method
 * to delete a DataTables row.
 *  @name Editor#preRemove
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 */

/**
 * Row removed event, fired when a row has been removed in the DataTable by a form
 * submission. This is called just after the fnDeleteRow call to the DataTable.
 *  @name Editor#remove
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 */

/**
 * As per the `postRemove` event - included for naming consistency.
 *  @name Editor#postRemove
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 */

/**
 * Set data event, fired when the data is gathered from the form to be used
 * to update the DataTable. This is a "global" version of `preCreate`, `preEdit`
 * and `preRemove` and can be used to manipulate the data that will be added
 * to the DataTable for all three actions
 *  @name Editor#setData
 *  @event
 *  @param {event} e jQuery event object
 *  @param {object} json The JSON object returned from the server
 *  @param {object} data The data that will be used to update the DataTable
 *  @param {string} action The action being performed by the form - 'create',
 *    'edit' or 'remove'.
 */

/**
 * Initialisation of the Editor instance has been completed.
 *  @name Editor#initComplete
 *  @event
 *  @param {event} e jQuery event object
 */


return Editor;
};


if ( typeof define === 'function' && define.amd ) {
	// Define as an AMD module if possible
	define( ['jquery', 'datatables'], factory );
}
else if ( typeof exports === 'object' ) {
    // Node/CommonJS
    factory( require( 'jquery' ), require( 'datatables' ) );
}
else if ( jQuery && !jQuery.fn.dataTable.Editor ) {
	// Otherwise simply initialise as normal, stopping multiple evaluation
	factory( jQuery, jQuery.fn.dataTable );
}

}(window, document));

