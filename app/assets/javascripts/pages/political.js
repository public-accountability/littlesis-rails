/**
 * Political page showing federal contributions
 *
 */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) {
      module.exports = factory(require('jQuery'), require('../common/utility'));
  } else {
    // Browser globals (root is window)
      root.political = factory(root.jQuery, root.utility);
  }
}(this, function ($, utility) {
  
  var store = {
    data: null,
    allRecipients: null,
    politicians: null,
    orgs: null
  };
  
  /**
   *  Retrieves contributions json for entity id
   *  integer -> callback([])
   */
  var getContributions = function (id, cb){
    $.getJSON('/entities/' + id + '/contributions', function(data){ cb(data); });
  };

  /**
   * Colors for donations categories: ["dem", "gop", "pac", "other", "out"]
   */
  var colors = ["#3333FF", "#E91D0E", "#b3cde3", "#bfbfbf", "#ccebc5"];

  /**
   * Creates D3 Graphic
   * Modeled after: https://bl.ocks.org/mbostock/3886208
   */
  var barChart = function(data){
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
	pieChart(store.data, d.data.year);
      })
      .on('mouseout', function(d){
	pieChart(store.data);
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
  var parseContributions = function(contributions){
    var years = ["1990", "1992", "1994", "1996", "1998", "2000", "2002", "2004", "2006", "2008", "2010", "2012","2014", "2016", "2018"];
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
  var contributionAggregate = function(parsedContributions){
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
   * Given array of objects with field 'amount' it returns the sum
   * @param {Array}
   * @returns {Number}
   */
  var sumAmount = function(arr) {
    return arr.reduce(function(acc, item) {
      return acc + item.amount;
    }, 0);
  };
  
  /**
   * Groups contributions by donor
   * @param {Array} contributions
   */
  var groupByDonor = function(contributions) {
    var total = sumAmount(contributions);

    var donorGroups = d3.nest()
      .key(function(d) { return d.donor_id; })
      .rollup(function(contributions) {
	return {
	  name: contributions[0].donor_name,
	  amount: sumAmount(contributions),
	  pct: sumAmount(contributions) / total
	};
      })
      .entries(contributions)
      .sort(function(a,b) {
	return b.value.amount - a.value.amount;
      });
    
    if (donorGroups.length < 8) {
      return donorGroups;
    } else {
      var otherDonors = donorGroups.slice(7).reduce(function(acc, contribution){
	acc.value.amount += contribution.value.amount;
	return acc;
      }, { "key": 'rest', "value": { name: 'others', amount: 0 } });
      otherDonors.value.pct = otherDonors.value.amount / total;
      return donorGroups.slice(0,7).concat(otherDonors);
    }

  };

  

  /**
   * Pie Chart of contributions
   * Modeled after: http://bl.ocks.org/mbostock/8878e7FD82034f1d63cf
   */
  var pieChart = function(parsedData, y){
    $('#political-pie-chart').html('<canvas width="200" height="200"></canvas>');
    var canvas = document.querySelector('#political-pie-chart canvas');
    var context = canvas.getContext("2d");
    var width = canvas.width;
    var height = canvas.height;
    var radius = Math.min(width, height) / 2;
    var year = (typeof y === 'undefined') ? false : y;
    // [{fields: party, amount }]
    var filteredByYear =  (year) ? parsedData.filter(function(d){ return (d.year === year); }) : parsedData;
    var data = contributionAggregate(filteredByYear);
    
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
  var groupByRecip = function(data, extType) {
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
            amount: sumAmount(leaves),
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
  var whoTheySupportButtons = function(){
    $('#who-they-support-buttons label').on('click',function(e){
      var selection = $(this).find('input').attr('name');
      if (selection === 'all') {
	whoTheySupport(store.allRecipients);
      } else if (selection === 'politicians') {
	whoTheySupport(store.politicians);
      } else if (selection === 'orgs') {
	whoTheySupport(store.orgs);
      } else {
	console.log('the name for the button must be: all, politicians, or orgs');
      }
    });
  };

  var entityLink = function(d) {
    return utility.entityLink(d.key, d.value.name, d.value.ext);
  };

  /**
   * input: d; d.value = rollup object from groupByRecip
   * output: string
   */
  var formatName = function(d) {
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
  var whoTheySupport = function(d) {
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
      .attr('xlink:href', entityLink)
      .append("text")
      .text(formatName)
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
   * Creates "Top Donors" graph
   * @param {Array} d
   */
  var topDonors = function(d){
    var container = '#top-donors';
    var w = $(container).width();
    var h = 500;
    var radius = Math.min(w, h) / 2;
    var colors = ['rgb(166,206,227)','rgb(31,120,180)','rgb(178,223,138)','rgb(51,160,44)','rgb(251,154,153)','rgb(227,26,28)','rgb(253,191,111)','rgb(255,127,0)','rgb(202,178,214)','rgb(106,61,154)','rgb(255,255,153)','rgb(177,89,40)'];
    //var colors = ['rgb(141,211,199)','rgb(255,255,179)','rgb(190,186,218)','rgb(251,128,114)','rgb(128,177,211)','rgb(253,180,98)','rgb(179,222,105)','rgb(252,205,229)','rgb(217,217,217)','rgb(188,128,189)','rgb(204,235,197)','rgb(255,237,111)'];
    var pieArcs = d3.pie()
	  .value(function(d) {
	    return d.value.amount;
	  })(d);

    var arc = d3.arc()
	  .padAngle(0.02)
	  .outerRadius(radius * 0.66)
	  .innerRadius(radius * 0.3);
    
    var labelArc = d3.arc()
    	  .outerRadius(radius * 0.9)
    	  .innerRadius(radius * 0.9);

    var lineStartArc = d3.arc()
    	  .outerRadius(radius * 0.55)
    	  .innerRadius(radius * 0.55);

    var lineEndArc = d3.arc()
    	  .outerRadius(radius * 0.8)
    	  .innerRadius(radius * 0.8);

    function isSmallSlice(d) {
      return (d.data.value.pct <= 0.05);
    }
    
    var svg = d3.select(container)
	.append("svg")
	.attr("width", w)
	.attr("height", h)
	.append("g")
        // Moving the center point. 1/2 the width and 1/2 the height
	.attr("transform", "translate(" + w/2 + "," + h/2 +")"); 

    var g = svg.selectAll("arc")
	.data(pieArcs)
	.enter().append("g")
	.attr("class", "arc");
    
    //arcs
    g
      .append("path")
      .attr("d", arc)
      .style("fill", function(d, i) {
    	return colors[i];
      });

    // lines
    g.
      append('line')
      .attr("x1", function(d) {
	return lineStartArc.centroid(d)[0];
      })
      .attr("y1", function(d) {
	return lineStartArc.centroid(d)[1];
      })
      .attr("x2", function(d) {
	return lineEndArc.centroid(d)[0];
      })
      .attr("y2", function(d) {
	return lineEndArc.centroid(d)[1];
      })
      .attr("stroke", "black")
      .attr("stroke-width", "1")
      .attr("visibility", "hidden");

    
    // text
    g
      .append("text")
      .attr("transform", function(d) {
        return "translate(" + labelArc.centroid(d) + ")";
      })
      .attr("text-anchor", "middle") //center the text on it's origin
      .style("fill", "black")
      .style("font", "bold 10px Arial")
      .attr("visibility", function(d){
	return isSmallSlice(d) ? "hidden" : "visible";
      })
      .text(function(d, i) {
    	return d.data.value.name;
      });

    // % labels
    g
      .filter(function(d) {
	return !isSmallSlice(d);
      })
      .append("text")
      .attr("transform", function(d) {
        return "translate(" + arc.centroid(d) + ")";
      })
      .attr("text-anchor", "middle")
      .style("fill", "white")
      .style("font", "bold 10px Arial")
      .text(function(d, i) {
    	return d3.format(".1%")(d.data.value.pct);
      });

    // show lines on hover
    g
      .on("mouseover", function(d) {
        d3.select(this).select('line').attr("visibility", "visible");
	if (isSmallSlice(d)) {
	  d3.select(this).select('text').attr("visibility", "visible");
	}
      })
      .on("mouseout", function(d) {
	d3.select(this).select('line').attr("visibility", "hidden");
	if (isSmallSlice(d)) {
	  d3.select(this).select('text').attr("visibility", "hidden");
	}
      });
    
  };

  /**
   * Kicks it all off
   */
  var init = function(showTopDonorChart){
    var id = $('#political-contributions').data('entityid');
    getContributions(id, function(contributions){
      // data //
      store.data = parseContributions(contributions);
      store.allRecipients = groupByRecip(contributions);
      store.politicians = groupByRecip(contributions, 'Person');
      store.orgs = groupByRecip(contributions, 'Org');
      
      // charts //
      barChart(store.data);
      pieChart(store.data);
      whoTheySupport(store.allRecipients);
      // dom events //
      whoTheySupportButtons();
      if (Boolean(showTopDonorChart)) {
	topDonors(groupByDonor(contributions));
      }
    });
  };


  return {
    getContributions: getContributions,
    barChart: barChart,
    pieChart: pieChart,
    parseContributions: parseContributions,
    contributionAggregate: contributionAggregate,
    groupByRecip: groupByRecip,
    groupByDonor: groupByDonor,
    whoTheySupportButtons: whoTheySupportButtons,
    whoTheySupport: whoTheySupport,
    formatName: formatName,
    init: init
  };
}));


