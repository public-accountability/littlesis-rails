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
entity.political.politicians = null;
entity.political.orgs = null;

// Toggles visibility of a related entity's additional relationships on a profile page
entity.relationshipsToggle = function(e) {
  $(e.target).closest('.relationship-section').find('.collapse').collapse('toggle');
};

/**
 *  Retrieves contributions json for entity id
 *  integer -> callback([])
 */
entity.political.getContributions = function (id, cb){
  $.getJSON('/entities/' + id + '/contributions', function(data){ cb(data); });
};

/**
 * Colors for donations categories: ["dem", "gop", "pac", "other", "out"]
 */
entity.political.colors = ["#3333FF", "#E91D0E", "#b3cde3", "#bfbfbf", "#ccebc5"];

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
  
  var labelText = {
    "dem": "Democrat",
    "gop": "Republican",
    'other': "3rd party/other",
    'pac': "Pacs",
    'out': "Outside spending"
  };

  var cats = ["dem", "gop", "pac", "other", "out"];
  var colors = entity.political.colors;
  
  var z = d3.scaleOrdinal().range(colors);

   // scale	
  x.domain(data.map(function(d){return d.year;}));
  var ymax = d3.max(data.map(function(d){ return d.amount; }));
  y.domain([0, ymax]);

  var stack = d3.stack()
        .keys(cats);
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

  var legend = svg.selectAll(".legend")
        .data(cats)
        .enter().append("g")
        .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; })
        .style("font", "9px sans-serif");

  legend.append("rect")
    .attr("x", 5)
    .attr("width", 15)
    .attr("height", 15)
    .attr("fill", z);

  legend.append("text")
    .attr("x", 23)
    .attr("y", 9)
    .attr("dy", ".35em")
    .attr("text-anchor", "left")
    .text(function(d) {  return labelText[d]; });
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
      pac: 0,
      out: 0,
      other: 0
    };
  });
  
  contributions.forEach(function(c){
    var i = years.indexOf(c.cycle); 
    
    // Skip the contribution if it's missing a recipient.
    if (c.recipcode) {
      var party = c.recipcode.slice(0,1);
    } else {
      return;
    }
    
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
      } else if (party === 'P') {
        cycles[i].pac += c.amount;
      } else if (party === 'O') {
        cycles[i].out += c.amount;
      }  else {
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
  var pac = {party: 'P', amount: 0};
  var out = {party: 'O', amount: 0};

  parsedContributions.forEach(function(x){
    dem.amount += x.dem;
    gop.amount += x.gop;
    ind.amount += x.other;
    pac.amount += x.pac;
    out.amount += x.out;
  });
  return [dem, gop, pac, ind, out];
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
  var colors = entity.political.colors;
  var year = (typeof y === 'undefined') ? false : y;
  // [{fields: party, amount }]
  var filteredByYear =  (year) ? parsedData.filter(function(d){ return (d.year === year); }) : parsedData;
  var data = entity.political.contributionAggregate(filteredByYear);
  
  var totalAmount = data.reduce(function(prev,curr){ return prev + curr.amount; }, 0);
  if (totalAmount < 1) { return; }   // return early if there are no donations;

  var totalFormatted = d3.format("$,.4r")(totalAmount);
  var demPct = d3.format('.0%')(data[0].amount / totalAmount);
  var gopPct = d3.format('.0%')(data[1].amount / totalAmount);
  var pacPct = d3.format('.0%')(data[2].amount / totalAmount);
  var indPct = d3.format('.0%')(data[3].amount / totalAmount);
  var outPct = d3.format('.0%')(data[4].amount / totalAmount);
  
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
  $('span.pacs').text(pacPct);
  $('span.outside-spending').text(outPct);
};

/**
 * Groups contributions by recipient and optionally filters by Person or Org
 * @param {Array} data - Contributions from getContributions()
 * @param {String|undefined} extType - "Person" or "Org" or undefined
 * @returns {Array} 
 */
entity.political.groupByRecip = function(data, extType) {
  function sortContributions(a,b){
    return b.value.amount - a.value.amount;
  }

  function filterContributions(contributions, extType){
    return contributions.filter(function(x){ return (x.value.ext === extType); } );
  }

  // Removes matches that don't have a joined LittleSis Entity
  var _data = data.filter(function(x){ return Boolean(x.recip_id); });

  var contributions = d3.nest()
       .key(function(d){ return String(d.recip_id); })
        // aggregate contributions by recipient
        .rollup(function(leaves){
          return {
            amount: leaves.reduce(function(p, c) { return p + c.amount; }, 0),
            name: leaves[0].recip_name,
            blurb: leaves[0].recip_blurb,
            recipcode: leaves[0].recipcode,
            ext: leaves[0].recip_ext,
            count: leaves.length
          };
        })
        .entries(_data)
        .sort(sortContributions);

  if (typeof extType === 'undefined') {
    return contributions;
  } else {
    return filterContributions(contributions, extType);
  }

};

/**
 * Sets event callbacks for the buttons to pick between showing politicians, orgs or all
 */
entity.political.whoTheySupportButtons = function(){
  var p = entity.political;
  $('#who-they-support-buttons label').on('click',function(e){
    var selection = $(this).find('input').attr('name');
    if (selection === 'all') {
      p.whoTheySupport(p.allRecipients);
    } else if (selection === 'politicians') {
      p.whoTheySupport(p.politicians);
    } else if (selection === 'orgs') {
      p.whoTheySupport(p.orgs);
    } else {
      console.log('the name for the button must be: all, politicians, or orgs');
    }
  });
};

entity.political.entityLink = function(d) {
  var url = '//littlesis.org/';
  if (d.value.ext === 'Person') {
    url += 'person/';
  } else {
    url += 'org/';
  }
  url += (d.key + '/'  + d.value.name.replace(' ', '_'));
  return url;
};

/**
 * input: d; d.value = rollup object from groupByRecip
 * output: string
 */
entity.political.formatName = function(d) {
  var party = d.value.recipcode.slice(0,1);
  if (d.value.ext === 'Person') {
    if (party === 'R' || party === 'D' || party === 'I') {
      return d.value.name + ' (' + party + ')';
    }
  }
  return d.value.name;  // default
};

/**
 * Creates "Who They Support" chart
 * @param {Array} data - output of groupByRecip
 */
entity.political.whoTheySupport = function(d) {
  var data = d.slice(0,10); // top 10
  
  var container = '#who-they-support';
  $(container).empty();
  
  var margin = {top: 10, right: 65, bottom: 10, left: 10};
  var w = $(container).width();
  var h = 35 * data.length;
  var offset = 330;

  var x = d3.scaleLinear()
        .range([0, (w - offset)])
        .domain([0, data[0].value.amount]);

  var y = d3.scaleBand()
        .domain(data.map(function(x,index){ return index; }))
        .range([0,h])
        .padding(0.2);

  var svg = d3.select(container).append('svg')
        .attr("width", w + margin.left + margin.right)
        .attr("height", h + margin.top + margin.bottom)
        .append("g")
        .attr("transform","translate(" + margin.left + "," + margin.top + ")");
  
  svg.selectAll('.amount-bars')
    .data(data)
    .enter().append('rect')
      .attr('fill', 'Rgba(168,221,181, 0.7)')
      .attr('x', '0')
      .attr('y', function(d, i){ return y(i); })
    .attr('height', y.bandwidth())
      .attr('width', function(d){
        return x(d.value.amount) + offset;
      });

  svg.selectAll('.name')
    .data(data).enter()
    .append("a")
      .attr("font-family", "sans-serif")
      .attr("font-size", "10px")
      .attr("fill", "black")
      .attr("font-weight", "bold")
      .attr('xlink:href', entity.political.entityLink)
    .append("text")
      .text(entity.political.formatName)
      .attr("x", '5')
      .attr("y", function(d, i) {
        return y(i) + (y.bandwidth() / 2);
      })
    .filter(function(d){ return (d.value.blurb) ? true : false; })
    .append('title')
      .text(function(d){ return d.value.blurb; });
  
  svg.selectAll('.amount')
    .data(data)
    .enter()
    .append("text")
    .attr("font-family", "sans-serif")
    .attr("font-size", "9px")
    .attr("fill", "black")
    .text(function(d) { return d3.format("$,.4r")(d.value.amount); })
    .attr("x", function(d, i){
      return x(d.value.amount) + offset + 5;
    })
    .attr("y", function(d, i) {
      return y(i) + (y.bandwidth() / 2);
    });
};

/**
 * Kicks it all off
 */
entity.political.init = function(){
  var p = entity.political;
  var id = $('#political-contributions').data('entityid');
  p.getContributions(id, function(contributions){
    // data //
    p.data = p.parseContributions(contributions);
    p.allRecipients = p.groupByRecip(contributions);
    p.politicians = p.groupByRecip(contributions, 'Person');
    p.orgs = p.groupByRecip(contributions, 'Org');
    // charts //
    p.barChart(p.data);
    p.pieChart(p.data);
    p.whoTheySupport(p.allRecipients);
    // dom events //
    p.whoTheySupportButtons();
  });
};
