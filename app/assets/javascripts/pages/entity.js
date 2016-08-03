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
entity.political.graphic = function(data){
  var container = '#political-contributions';
  var margin = {top: 10, right: 10, bottom: 30, left: 40};
  var w = $(container).width() - 20;
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
    .attr("x", function(d){ return x(d.data.year); })
    .attr("y", function(d){ return y(d[1])})
    .attr("height",function(d) { return y(d[0])- y(d[1]) })
    .attr("width", x.bandwidth());

  // add the x Axis
  svg.append("g")
    .attr("transform", "translate(0," + h + ")")
    .call(d3.axisBottom(x));

  // add the y Axis
  svg.append("g")
    .call(d3.axisLeft(y));

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
 * Kicks it all off
 */
entity.political.init = function(){
  var id = $('#political-contributions').data('entityid');
  entity.political.getContributions(id, function(contributions){
    var data = entity.political.parseContributions(contributions);
    entity.political.graphic(data);
  });
};
