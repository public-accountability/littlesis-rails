var entity = {}; 

// Toggles visibility of entity summary
entity.summaryToggle = function(){
  $('.summary-excerpt').toggle();
  $('.summary-full').toggle();
  $('.summary-show-more').toggle();
  $('.summary-show-less').toggle();
};

entity.political = {};

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

  var z = d3.scaleOrdinal()
        .range(["#3333FF", "#EE3523"]);

   // scale	
  x.domain(data.map(function(d){return d.year;}));
  var ymax = d3.max(data.map(function(d){ return d.amount; }));
  y.domain([0, ymax]);

  var stack = d3.stack()
        .keys(["dem", "gop"]);
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
    .attr('fill', function(d){ return z(d.key)})
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
    .attr("y", function(d){ return y(d[1])})
    .attr("height",function(d) { return y(d[0])- y(d[1]) })
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
    
    if (party === 'D') {
      cycles[i].dem += c.amount;
    } else if (party === 'R') {
      cycles[i].gop += c.amount;
    } else {
      cycles[i].other += c.amount;
    }
  });
  return cycles;
};

/**
 * [{}] (output of parseContributions) -> [{}]
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
 * Modeled after: http://bl.ocks.org/mbostock/8878e7fd82034f1d63cf
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
 * Kicks it all off
 */
entity.political.init = function(){
  var id = $('#political-contributions').data('entityid');
  entity.political.getContributions(id, function(contributions){
    entity.political.data = entity.political.parseContributions(contributions);
    entity.political.barChart(entity.political.data);
    entity.political.pieChart(entity.political.data);
  });
};
