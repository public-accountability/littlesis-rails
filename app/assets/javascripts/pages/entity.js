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
 */
entity.political.graphic = function(data){
  var container = '#political-contributions';
  var margin = {top: 10, right: 10, bottom: 30, left: 40};
  var w = $(container).width() - 20;
  var h = 300;
  
  var x = d3.scaleBand()
        .range([0, w])
        .padding(0.1);
  
  var y = d3.scaleLinear()
        .range([h,0]);
  
  // scale 
  x.domain(data.map(function(d){return d.year;}));
  var ymax = d3.max(data.map(function(d){ return d.amount; }));
  y.domain([0, ymax]);

  
  var svg = d3.select(container).append('svg')
        .attr("width", w + margin.left + margin.right)
        .attr("height", h + margin.top + margin.bottom)
        .append("g")
        .attr("transform","translate(" + margin.left + "," + margin.top + ")");
  
  svg.selectAll(".bar")
    .data(data)
    .enter().append("rect")
    .attr("class", "bar")
    .attr("x", function(d) { return x(d.year); })
    .attr("width", x.bandwidth())
    .attr("y", function(d) { return y(d.amount); })
    .attr("height", function(d){ return (h - y(d.amount)); });


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
 * [] -> [{}]
 */
entity.political.parseContributions = function(contributions){
  var cycles = {
    "1990": 0,"1992": 0,"1994": 0,"1996": 0,"1998": 0,"2000": 0,
    "2002": 0,"2004": 0,"2006": 0,"2008": 0,"2010": 0,"2012": 0,
    "2014": 0,"2016": 0
  };
  contributions.forEach(function(c){
    cycles[c.cycle] += c.amount;
  });
  
  return Object.keys(cycles).sort().map(function(key){
    return { year: key, amount: cycles[key] };
  });
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
