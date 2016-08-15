var matchDonations = {
  table: null,
  entity_id: null
};

matchDonations.getPotentialMatches = function(id, cb) {
  $.getJSON('/entities/' + id + '/potential_contributions', function(data){
    cb(data);
  });
};

matchDonations.sourceLink = function(microfilm) {
  if (microfilm) {
    return '<a target="_blank" href="http://docquery.fec.gov/cgi-bin/fecimg/?' 
      + microfilm + '">' + microfilm + '</a>';
  } else {
    return '';
  }
};

matchDonations.processData = function(data) {
  console.log(data);
  return data.map(function(x){
    x.address = x.city + ", " + x.state + " " + x.zip;
    x.sourceLink = matchDonations.sourceLink(x.microfilm);
   return x;
  });
  
}


matchDonations.datatable = function(data) {
  var table = $('#donations-table').DataTable( {
    data: matchDonations.processData(data),
    lengthChange: false,
    "dom": '<"toolbar">frtip',
    columns: [
      { data: 'contrib', title: "Name" },
      { data: 'address', title: "City" },
      { data: 'employer', title: "Employer" },
      { data: 'date', title: "Date" },
      { data: 'sourceLink', title: "FEC Source" },
      { data: 'transactiontype', title: "Transaction<br>Type" }
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
      // this limits it to only one selected at a time
      // table.$('tr.selected').removeClass('selected');
      $(this).addClass('selected');
    }
  });
};

// #match-the-donation
matchDonations.createMatchButton = function(){
  var html = '<button type="button" id="match-the-donation" class="btn btn-primary">Match Selected</button>';
  $("div.toolbar").html(html);
};

matchDonations.matchRequest = function(donations){
  var url =  "/entities/" + matchDonations.entity_id + "/match_donation";
  $.post(url, {'payload': donations})
     .done(function(r){ console.log(r); });
  // post -> ajax /entities/id/12345 {os_donation_id: 1234}
};

matchDonations.onClickMatchButton = function(table){
  $('#match-the-donation').click(function(){
    var selected = table.rows('.selected').data().toArray();
    if (selected.length > 0 ) {
      matchDonations.matchRequest(selected.map(function(x){ return x.id; }));
      table.rows('.selected').remove().draw( false );
    }
  });
};

matchDonations.init = function(){
  var id = $('#match-donations').data('entityid');
  matchDonations.entity_id = id;
  matchDonations.getPotentialMatches(id, matchDonations.datatable);
};
