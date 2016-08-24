var entity = {}; 

// Toggles visibility of entity summary
entity.summaryToggle = function(){
  $('.summary-excerpt').toggle();
  $('.summary-full').toggle();
  $('.summary-show-more').toggle();
  $('.summary-show-less').toggle();
};

entity.political = {};
entity.political.data = null;

/**
 *  Retrieves contributions json for entity id
 *  integer -> callback([])
 */
entity.political.getContributions = function (id, cb){
  $.getJSON('/entities/' + id + '/contributions', function(data){ cb(data); });
};

/**
 * Creates D3 Graphic
 * Modeled after: https://bl.ocks.org/mbostock/3886208
 */
entity.political.barChart = function(data){
  var container = '#political-contributions';
  var margin = {top: 10, right: 20, bottom: 30, left: 60};
  var w = $(container).width() - 40;
  var h = 250;
  
  var x = d3.scaleBand()
        .range([0, w])
        .padding(0.2);
  
  var y = d3.scaleLinear()
        .range([h,0]);

  var z = d3.scaleOrdinal().range(["#3333FF", "#EE3523", "#bfbfbf"]);

   // scale	
  x.domain(data.map(function(d){return d.year;}));
  var ymax = d3.max(data.map(function(d){ return d.amount; }));
  y.domain([0, ymax]);

  var stack = d3.stack()
        .keys(["dem", "gop", "other"]);
  //   .order(d3.stackOrderNone)
  //   .offset(d3.stackOffsetNone);

  var series = stack(data);
       
  var svg = d3.select(container).append('svg')
        .attr("width", w + margin.left + margin.right)
        .attr("height", h + margin.top + margin.bottom)
        .append("g")
        .attr("transform","translate(" + margin.left + "," + margin.top + ")");

   svg.selectAll('.series')
    .data(series)
    .enter().append("g")
    .attr('class', 'series')
    .attr('fill', function(d){ return z(d.key); })
    .selectAll("rect")
    .data(function(d){ return d; })
    .enter().append('rect')
    .on('mouseover', function(d){
      entity.political.pieChart(entity.political.data, d.data.year);
    })
    .on('mouseout', function(d){
      entity.political.pieChart(entity.political.data);
    })
     .attr("x", function(d){ return x(d.data.year); })
    .attr("y", function(d){ return y(d[1]); })
    .attr("height",function(d) { return y(d[0])- y(d[1]); })
    .attr("width", x.bandwidth());

  // add the x Axis
  svg.append("g")
    .attr("transform", "translate(0," + h + ")")
    .call(d3.axisBottom(x));

  // add the y Axis
  var yAxis = d3.axisLeft(y).ticks(5).tickFormat(d3.format("$,.2r"));
  svg.append("g")
    .call(yAxis);

};


/**
 * Takes [] of contributions and calculates amount per year
 * Groups by year * party
 * [{}] -> [{}]
 */
entity.political.parseContributions = function(contributions){
  var years = ["1990", "1992", "1994", "1996", "1998", "2000", "2002", "2004", "2006", "2008", "2010", "2012","2014", "2016"];
  var cycles = years.map(function(year){
    return {
      year: year,
      amount: 0,
      dem: 0,
      gop: 0,
      other: 0
    };
  });
  
  contributions.forEach(function(c){
    var i = years.indexOf(c.cycle); 
    var party = c.recipcode.slice(0,1);
  
    cycles[i].amount += c.amount;
    
    // Ignoring donations less than 0. There are negative donations -- refunds.
    // However, these negative values will cause issues
    // with d3 formatting on some profiles, so I'm excluding them until
    // a better solution is reached
    if (c.amount > 0) {

      if (party === 'D') {
        cycles[i].dem += c.amount;
      } else if (party === 'R') {
        cycles[i].gop += c.amount;
      } else {
        cycles[i].other += c.amount;
      }

    }
  });
  return cycles;
};

/**
 * [{}] (output of parseContributions) -> [{}]
 * Groups by party
 */
entity.political.contributionAggregate = function(parsedContributions){
  var dem = {party: 'D', amount: 0};
  var gop = {party: 'R', amount: 0};
  var ind = {party: 'I', amount: 0};
  parsedContributions.forEach(function(x){
    dem.amount += x.dem;
    gop.amount += x.gop;
    ind.amount += x.other;
  });
  return [dem, gop, ind];
};

/**
 * Pie Chart of contributions
 * Modeled after: http://bl.ocks.org/mbostock/8878e7FD82034f1d63cf
 */
entity.political.pieChart = function(parsedData, y){
  $('#political-pie-chart').html('<canvas width="200" height="200"></canvas>');
  var canvas = document.querySelector('#political-pie-chart canvas');
  var context = canvas.getContext("2d");
  var width = canvas.width;
  var height = canvas.height;
  var radius = Math.min(width, height) / 2;
  var colors = ["#3333FF", "#EE3523", "#bfbfbf"];
  var year = (typeof y === 'undefined') ? false : y;

  // [{fields: party, amount }]
  var filteredByYear =  (year) ? parsedData.filter(function(d){ return (d.year === year); }) : parsedData;
  var data = entity.political.contributionAggregate(filteredByYear);
  
  var totalAmount = data.reduce(function(prev,curr){ return prev + curr.amount; }, 0);
  if (totalAmount < 1) { return; }   // return early if there are no donations;

  var totalFormatted = d3.format("$,.4r")(totalAmount);
  var demPct = d3.format('.0%')(data[0].amount / totalAmount);
  var gopPct = d3.format('.0%')(data[1].amount / totalAmount);
  var indPct = d3.format('.0%')(data[2].amount / totalAmount);
  
  var arc = d3.arc()
        .outerRadius(radius - 20)
        .innerRadius(radius- 43)
        .padAngle(0.04)
        .context(context);

  var pie = d3.pie()
        .value(function(d){ return d.amount; });
  
  context.translate(width / 2, height / 2);
  
  var arcs = pie(data);
  
  arcs.forEach(function(d, i) {
    context.beginPath();
    arc(d);
    context.fillStyle = colors[i];
    context.fill();
  });

  if (year) {
    context.font = '12px sans-serif';
    context.textAlign = 'center';
    context.fillStyle = '#000';
    context.fillText(year, 0, 0);
  }

  $('#pie-info').removeClass('invisible');
  $('span.total-amount').text(totalFormatted);
  $('span.republican').text(gopPct);
  $('span.democrat').text(demPct);
  $('span.independent').text(indPct);
  
};

/**
 * Uses d3.nest to group by recipient and (optionally) by type
 * [{}] => [{Org}, {person}]
 */
entity.political.groupByRecip = function(data, groupByType) {
  // Removes matches that don't have a joined LittleSis Entity
  var _data = data.filter(function(x){ return Boolean(x.recip_id); });

  var n = d3.nest();
  
  if (groupByType) {
    n.key(function(d){ return d.recip_ext; }).sortKeys(d3.ascending);
  }
  
  n.key(function(d){ return String(d.recip_id); })
    // aggregate contributions by recipient
    .rollup(function(leaves){
      return {
        amount: leaves.reduce(function(p, c) { return p + c.amount; }, 0),
        name: leaves[0].recip_name,
        blurb: leaves[0].recip_blurb,
        ext: leaves[0].recip_ext,
        count: leaves.length
      };
    });
  
  function sortContributions(a,b){
   return b.value.amount - a.value.amount;
  }
  // sort by contribution amount to each entity
  if (groupByType) {
    return n.entries(_data).map(function(x){
      x.values = x.values.sort(sortContributions);
      return x; 
    });
  } else {
    return n.entries(_data).sort(sortContributions);
  }

};

/**
 * Chart of supported 
 * input: [{}] (output of groupByRecip)
 */
entity.political.whoTheySupport = function(data) {
  //console.log(data);
  var container = '#politicians-supported';
  var margin = {top: 10, right: 10, bottom: 10, left: 10};
  var w = $(container).width() - 20;
  var h = 350;
  
  var orgs = data[0].values;
  var politicans = data[1].values;

  var svg = d3.select(container).append('svg')
        .attr("width", w + margin.left + margin.right)
        .attr("height", h + margin.top + margin.bottom)
        .append("g")
        .attr("transform","translate(" + margin.left + "," + margin.top + ")");
  
  svg.selectAll('rect')
    .data(data[1].values, function(d){ });
};



/**
 * Kicks it all off
 */
entity.political.init = function(){
  var id = $('#political-contributions').data('entityid');
  entity.political.getContributions(id, function(contributions){
    // data //
    entity.political.data = entity.political.parseContributions(contributions);
    entity.political.groupedByType = entity.political.groupByTypeAndRecip(contributions);
    entity.political.groupedByRecip = entity.political.groupByRecip(contributions);
    // charts //
    entity.political.barChart(entity.political.data);
    entity.political.pieChart(entity.political.data);
    entity.political.whoTheySupport(entity.political.groupedByType);
  });
};
