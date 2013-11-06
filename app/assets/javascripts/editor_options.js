window.Bootsy = window.Bootsy || {};

var pageStylesheets = [];
$('link[rel="stylesheet"]').each(function () {
  pageStylesheets.push($(this).attr('href'));
});

window.Bootsy.options = {
  parserRules: {
    classes: {
      "wysiwyg-color-silver" : 1,
      "wysiwyg-color-gray" : 1,
      "wysiwyg-color-white" : 1,
      "wysiwyg-color-maroon" : 1,
      "wysiwyg-color-red" : 1,
      "wysiwyg-color-purple" : 1,
      "wysiwyg-color-fuchsia" : 1,
      "wysiwyg-color-green" : 1,
      "wysiwyg-color-lime" : 1,
      "wysiwyg-color-olive" : 1,
      "wysiwyg-color-yellow" : 1,
      "wysiwyg-color-navy" : 1,
      "wysiwyg-color-blue" : 1,
      "wysiwyg-color-teal" : 1,
      "wysiwyg-color-aqua" : 1,
      "wysiwyg-color-orange" : 1,
      "wysiwyg-float-left": 1,
      "wysiwyg-float-right": 1
    },

    tags: {
      "b":  {},
      "i":  {},
      "br": {},
      "ol": {},
      "ul": {},
      "li": {},
      "h1": {},
      "h2": {},
      "h3": {},
      "small": {},
      "p": {},
      "blockquote": {},
      "u": 1,
      "cite": {
        "check_attributes": {
          "title": "alt"
        }
      },
      "img": {
        "check_attributes": {
          "width": "numbers",
          "alt": "alt",
          "src": "src",
          "height": "numbers"
        },
        "add_class": {
          "align": "align_img"
        }
      },

      "a":  {
        set_attributes: {
          target: "_blank",
          rel:    "nofollow"
        },
        check_attributes: {
          href:   "url" // important to avoid XSS
        }
      },
      "span": { check_attributes: { style: "style" } },
      "div": { check_attributes: { style: "style" } },
      // to allow save and edit files with code tag hacks
      "code": 1,
      "pre": 1,

      //skomputer additions
      "em": {},
      "strong": {},
      "table": { "check_attributes": { "style": "style" } },
      "th": { "check_attributes": { "style": "style" } },
      "tr": { "check_attributes": { "style": "style" } },
      "td": { "check_attributes": { "style": "style" } }
    }
  },
  color: true,
  stylesheets: pageStylesheets
};