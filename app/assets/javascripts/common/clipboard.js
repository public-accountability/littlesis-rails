// Sets any matching element up as a copy-to-clipboard button,
// taking its content from the element's data-clipboard-text attribute.
// See https://clipboardjs.com/
$(document).ready(function() {
  new clipboardjs('.copy_button')
})
