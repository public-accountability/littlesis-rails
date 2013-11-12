$(window).ready(function() {
  $(".more_link").on("click", function () {
  	var id = $(this).data("target");
    var remainder = $("#" + id + "_remainder");

    if (remainder.hasClass("expanded")) {
	  	remainder.hide("blind");
	  	remainder.toggleClass("expanded")
	  	$(this).html("more &raquo;");
	  } else {
	    remainder.show("blind");
	  	remainder.toggleClass("expanded")
	    $(this).html("&laquo; less");
	  }
  });
});