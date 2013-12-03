// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.bettertabs
//= require bootstrap
//= require bootsy
//= require editor_options
//= reuqire more_link
//= require twitter/typeahead
//= require_tree .

$(document).ready(function() {
	$('button[data-dismiss-id]').on("click", function() {
		var id = $(this).attr('data-dismiss-id');
		$.ajax("/home/dismiss", {
			data: { id: id },
			type: 'POST',
			success: function(data) {
				$('#' + data.id).hide('blind');
			}
		});
	});
});