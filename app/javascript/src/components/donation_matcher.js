import utility from '../common/utility.mjs'
import datatable from 'datatables.net'

export default function DonationMatcher() {
  var matchDonations = {
    table: null,
    entity_id: null,
    mode: null, // "MATCH" or "UNMATCH"
    columns: {
      match: [
      { data: 'contrib', title: "Name", width: '30%' },
      { data: 'address', title: "City", width: '25%' },
      { data: 'employer', title: "Employer", width: '25%' },
      { data: 'date', title: "Date", width: '10%' },
      { data: 'sourceLink', title: "FEC Source", width: '10%'}
      ],
      unmatch: [
      { data: 'contrib', title: "Name" },
      { data: 'address', title: "City" },
      { data: 'employer', title: "Employer" },
      { data: 'date', title: "Date" },
      { data: 'amount', title: "Amount"},
      { data: 'entityLink', title: "Recipient"},
      { data: 'sourceLink', title: "FEC Source" }
      ]
    }
  }

  matchDonations.getPotentialMatches = function(id, cb) {
    $.getJSON('/entities/' + id + '/potential_contributions', function(data){
      cb(data)
    })
  }

  matchDonations.getExistingMatches = function(id, cb) {
    $.getJSON('/entities/' + id + '/contributions', function(data){
      cb(data)
    })
  }

  matchDonations.sourceLink = function(microfilm) {
    if (microfilm) {
      return '<a target="_blank" href="http://docquery.fec.gov/cgi-bin/fecimg/?'
        + microfilm + '">' + microfilm + '</a>'
    } else {
      return ''
    }
  }

  matchDonations.processData = function(data) {
    return data.map(function(x){
      x.address = x.city + ", " + x.state + " " + x.zip
      x.sourceLink = matchDonations.sourceLink(x.microfilm)
      if (matchDonations.mode === 'UNMATCH') {
        if (x.recip_id) {
          x.entityLink = '<a target="_blank" href="' + utility.entityLink(x.recip_id, x.recip_name, x.recip_ext) + '">' + x.recip_name + "</a>"
        } else {
          x.entityLink = ''
        }
      }
      return x
    })
  }

  matchDonations.datatable = function(data, columns) {
    var table = $('#donations-table').DataTable( {
      data: matchDonations.processData(data),
      lengthChange: false,
      "dom": '<"toolbar">frtip',
      columns: columns
    })
    matchDonations.table = table
    matchDonations.setupTable(table)}

  matchDonations.setupTable = function(table) {
    matchDonations.rowClick(table)
    matchDonations.createToolBar()
    matchDonations.onClickMatchButton(table)
    matchDonations.onClickSelectAll()
    matchDonations.onPageLenSelect(table)
  }

  matchDonations.rowClick = function() {
    $('#donations-table tbody').on( 'click', 'tr', function() {
      if ( $(this).hasClass('selected') ) {
        $(this).removeClass('selected')
      }
      else {
        $(this).addClass('selected')
      }
    })
  }

  matchDonations.selectHtml = '<span class="m-left-1em text-muted">show:</span><select id="page-length-select"><option>10</option><option>20</option><option>30</option><option>50</option></select>'

  // Creates Toolbar with: match donatons button, loading icon, and selected all
  // #match-the-donation, .load, #select-all
  matchDonations.createToolBar = function(){
    var html = '<button type="button" id="match-the-donation" class="btn btn-primary">'
    html += (matchDonations.mode === 'MATCH') ? "Match Selected" : "Unmatch Selected"
    html += '</button>'
    html += '<div class="loading"></div>'
    html += '<button type="button" id="select-all" class="btn btn-primary">Select all</button>'
    html += matchDonations.selectHtml
    $("div.toolbar").html(html)
  }


  matchDonations.matchRequest = function(donations){
    var url =  "/entities/" + matchDonations.entity_id
    url += (matchDonations.mode === 'MATCH') ? "/match_donation" : "/unmatch_donation"

    $.post(url, {'payload': donations})
      .done(function(){
        $('#match-donations .toolbar .loading').html('<span class="bi bi-check" aria-hidden="true"></span>')
        $('#match-donations .toolbar .loading span').fadeOut(1100)
      })
    .fail(function(){
      $('#match-donations .toolbar .loading').html('<span class="bi bi-x-lg" aria-hidden="true"></span>')
      $('#match-donations .toolbar .loading span').fadeOut(1000)
    })
  }

  matchDonations.onClickMatchButton = function(table){
    $('#match-the-donation').click(function(){
      var selected = table.rows('.selected').data().toArray()
      if (selected.length > 0 ) {
        $('#match-donations .toolbar .loading').html('<span class="bi bi-gear-wide spin-icon" aria-hidden="true"></span>')
        matchDonations.matchRequest(selected.map(function(x){
          if (matchDonations.mode === 'MATCH') {
            return x.id
          } else {
            return x.os_match_id
          }
        }))
        table.rows('.selected').remove().draw( false )
      }
    })
  }

  matchDonations.onClickSelectAll = function() {
    $('#select-all').click(function() {
      $('#donations-table tbody tr').addClass('selected')
    })
  }

  matchDonations.onPageLenSelect = function(table) {
    $('#page-length-select').change(function(){
      var len = Number($(this).find('option:selected').text())
      table.page.len(len).draw()
    })
  }

  matchDonations.init = function(){
    matchDonations.mode = 'MATCH'
    var id = $('#match-donations').data('entityid')
    matchDonations.entity_id = id
    matchDonations.getPotentialMatches(id, function(data){
      matchDonations.datatable(data, matchDonations.columns.match)
    })
  }


  /**
   * The "unmatch donation" works very similar to the match donations page.
   * Some of the html tag ids might be confusing because they do the opposite.
   */
  matchDonations.unmatch_init = function(){
    matchDonations.mode = 'UNMATCH'
    var id = $('#match-donations').data('entityid')
    matchDonations.entity_id = id
    matchDonations.getExistingMatches(id, function(data){
      matchDonations.datatable(data, matchDonations.columns.unmatch)
    })
  }

  return matchDonations
}
