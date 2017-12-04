function NyMatchDonations(mode, entity_id) {
  this.mode = mode; // 'match' or 'unmatch'
  this.entity_id = entity_id;
  this.table = null; // store reference to Datatable object
  
  // int, func -> callback([{}])
  this.potentialMatches = function(id, cb) {
    $.getJSON('/nys/potential_contributions', {entity: id }, function(data) { cb(data); }); 
  };

  // int, func -> callback([{}])
  this.existingMatches = function(id, cb) {
    $.getJSON('/nys/contributions', {entity: id }, function(data){ cb(data); }); 
  };
  
  this.columns =  {
    match: [
      { data: 'name', title: "Name", width: '25%' },
      { data: 'address', title: "Address", width: '20%' },
      { data: 'amount', title: "Amount", width: '10%' },
      { data: 'transaction_code', title: 'Transaction Code', width: '10%'}, 
      { data: 'date', title: "Date", width: '10%'},
      { data: 'filer_name', title: 'Recipient', width: '25%'}
    ],
    unmatch: [
      { data: 'name', title: "Name", width: '25%' },
      { data: 'address', title: "Address", width: '20%' },
      { data: 'amount', title: "Amount", width: '7%' },
      { data: 'transaction_code', title: 'Transaction Code', width: '10%'}, 
      { data: 'date', title: "Date", width: '10%'},
      { data: 'filer_name', title: 'Recipient', width: '23%'},
      { data: 'filer_in_littlesis', title: 'Filer in LittleSis?', width: '5%' }
    ]
  };

  this.createToolBar = function(){
    var html = '';
    html += '<button type="button" id="match-the-donation" class="btn btn-primary">';
    html += (this.mode === 'match') ? "Match Selected" : "Unmatch Selected";
    html += '</button>';
    html += '<div class="loading"></div>';
    html += '<button type="button" id="select-all" class="btn btn-primary">Select all</button>';
    html += '<span class="m-left-1em text-muted">show:</span><select id="page-length-select"><option>10</option><option>20</option><option>30</option><option>50</option></select>';
    $("div.toolbar").html(html);
  }.bind(this);


   this.rowClick = function() {
    $('#donations-table tbody').on( 'click', 'tr', function () {
      if ( $(this).hasClass('selected') ) {
         $(this).removeClass('selected');
      }
      else {
        $(this).addClass('selected');
      }
    });
  };

  this.onClickSelectAll = function() {
    $('#select-all').click(function () {
      $('#donations-table tbody tr').addClass('selected');
    });
  };

  this.onPageLenSelect = function(table) {
    $('#page-length-select').change(function(){
      var len = Number($(this).find('option:selected').text());
      table.page.len(len).draw();
    });
  };

  
  this.matchRequest = function(ids) {
    var url = '/nys/' + this.mode + '_donations';
    var payload = (this.mode == 'match') ?
	{disclosure_ids: ids, donor_id: this.entity_id } :
	{ny_match_ids: ids };
    
    $.post(url, {payload: payload})
      .done(function(r){ 
        $('#match-donations .toolbar .loading').html('<span class="glyphicon glyphicon-ok" aria-hidden="true"></span>');
        $('#match-donations .toolbar .loading span').fadeOut(1100);
      })
      .fail(function(r){
        $('#match-donations .toolbar .loading').html('<span class="glyphicon glyphicon-remove" aria-hidden="true"></span>');
        $('#match-donations .toolbar .loading span').fadeOut(1000);
      });
  }.bind(this);

  this.onClickMatchButton = function(){
    var that = this;
    $('#match-the-donation').click(function(){
      var ids = that.table.rows('.selected').data().toArray().map(function(x){
        return (that.mode === 'match') ? x.disclosure_id : x.ny_match_id;
      });
      if (ids.length > 0) {
        $('#match-donations .toolbar .loading').html('<span class="glyphicon glyphicon-cog spin-icon" aria-hidden="true"></span>');
        that.matchRequest(ids);
        that.table.rows('.selected').remove().draw( false );
      }
    });
  }.bind(this);

  this.datatable = function(data){
    this.table = $('#donations-table').DataTable( {
      data: data,
      lengthChange: false,
      "dom": '<"toolbar">frtip',
      columns: this.columns[this.mode]
    });
    this.createToolBar();
    this.rowClick();
    this.onClickSelectAll();
    this.onPageLenSelect(this.table);
    this.onClickMatchButton();
  }.bind(this);

  this.init = function(){
    if (this.mode === 'match') {
      this.potentialMatches(this.entity_id, this.datatable);
    } else if (this.mode === 'unmatch') {
      this.existingMatches(this.entity_id, this.datatable);
    } else {
      console.error("The mode must be 'match' or 'unmatch' ");
    }
    
  }.bind(this);

};
