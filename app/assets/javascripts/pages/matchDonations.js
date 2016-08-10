var matchDonations = {};
matchDonations.table = null;

matchDonations.getPotentialMatches = function(id, cb) {
  $.getJSON('/entities/' + id + '/potential_contributions', function(data){
    cb(data);
  });
};

matchDonations.datatable = function(data) {
  var table = $('#donations-table').DataTable( {
    data: data,
    lengthChange: false,
    "dom": '<"toolbar">frtip',
    columns: [
      { data: 'contrib', title: "Name" },
      { data: 'city', title: "City" },
      { data: 'employer', title: "Employer" },
      { data: 'microfilm', title: "FEC Source" }
    ]
  });
  matchDonations.table = table;
  matchDonations.setupTable(table);};

matchDonations.setupTable = function(table) {
  matchDonations.rowClick(table);
  matchDonations.createMatchButton();
  matchDonations.onClickMatchButton(table);
};

matchDonations.rowClick = function(table) {
  $('#donations-table tbody').on( 'click', 'tr', function () {
    if ( $(this).hasClass('selected') ) {
       $(this).removeClass('selected');
    }
    else {
      table.$('tr.selected').removeClass('selected');
      $(this).addClass('selected');
    }
  });
};

// #match-the-donation
matchDonations.createMatchButton = function(){
  var html = '<button type="button" id="match-the-donation" class="btn btn-primary">Match Selected</button>';
  $("div.toolbar").html(html);
};

matchDonations.matchRequest = function(donation){
  console.log(donation);
  // post -> ajax /entities/id/12345 {os_donation_id: 1234}
};

matchDonations.onClickMatchButton = function(table){
  $('#match-the-donation').click(function(){
    var selected = table.row('.selected').data();
    if (typeof selected === 'object') {
      matchDonations.matchRequest(selected);
      table.row('.selected').remove().draw( false );
    }
  });
};

matchDonations.init = function(){
  var id = $('#match-donations').data('entityid');
  matchDonations.getPotentialMatches(id, matchDonations.datatable);
};
