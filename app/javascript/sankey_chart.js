import * as d3 from "d3"

import { sankey, sankeyLinkHorizontal } from 'd3-sankey'

import { get } from './src/common/http.mjs'

const ENTITY_IDS =  [1033, 1034, 1035, 1045, 1046, 257396]

async function main() {
}

function chart() {
  // const data = {
//     "nodes": [
//       { "id": 0, "name": "nodeA" },
//       { "id": 1, "name": "nodeB" },
//       { "id": 2, "name": "nodeC" },
//       { "id": 3, "name": "nodeD" },
//       { "id": 4, "name": "nodeE" }
//     ],
//     "links": [
//       { "source": 0, "target": 2, "value": 2, "sName": "A", "tName": "C" },
//       { "source": 1, "target": 2, "value": 2, "sName": "B", "tName": "C" },
//       { "source": 1, "target": 3, "value": 2, "sName": "B", "tName": "D" },
//       { "source": 0, "target": 4, "value": 2, "sName": "A", "tName": "E" },
//       { "source": 2, "target": 3, "value": 2, "sName": "C", "tName": "D" },
//       { "source": 2, "target": 4, "value": 2, "sName": "fC", "tName": "E" },
//       { "source": 3, "target": 4, "value": 4, "sName": "D", "tName": "E" }
//     ]
//   }

  const margin = { top: 10, right: 10, bottom: 10, left: 10 }
  const width = 450 - margin.left - margin.right
  const height = 480 - margin.top - margin.bottom
  const color = d3.scaleOrdinal(d3.schemeAccent)

  // [left, top], [right, bottom] = [[x0, y0], [x1, y1]]
  const extent = [[margin.left, margin.top], [width - margin.right, height - margin.bottom]]

  const tooltip = d3.select('body')
        .append('div')
        .attr('id', 'sankey-tooltip')
        .style('opacity', 0)

  const svg = d3.select("#sankey-chart")
        .append("svg")
        .attr("width", width)
        .attr("width", height)
        .attr("viewBox", [0, 0, width, height])
        .attr("style", "max-width: 100%; height: auto; height: intrinsic;");
        // .append("g")
        // .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  const generator = sankey()
    .nodeId(d => d.id)
    .nodeWidth(30)
    .nodePadding(300)
    .iterations(7)  // default = 6
    .extent(extent) // default =  [[0, 0], [1, 1]]

  const chart = generator(data)

  const link = svg
        .append("g")
        .selectAll('.sankey-link')
        .data(chart.links)
        .enter()
        .append("path")
        .attr("class", "sankey-link")
        .attr("d", sankeyLinkHorizontal())
        .attr('pointer-events', 'visibleStroke')
        .attr("stroke-width", d => (d.width / 2) )
        .on("mouseover", function(e, d) {
          let title = `${d.sName}<--${d.value}-->${d.tName}`
          // tooltip.transition().duration(200).style("opacity", .9)
          tooltip
            .style("opacity", .9)
            .html(`<p>${title}</p>`)
            .style("left", (e.pageX) + "px")
            .style("top", (e.pageY) + "px")
        })
        .on("mouseout", function(e) {
          // tooltip.transition().duration(300).style("opacity", 0)
          tooltip.style("opacity", 0)
        })
        .on("mousemove", function(e) {
          d3.select('#sankey-tooltip')
            .style('left', e.pageX + 'px')
            .style('top', e.pageY + 'px')
        })

  const node = svg
    .append("g")
    .attr("stroke-width", 2)
    .attr("stroke", "red")
    .selectAll("rect")
    .data(chart.nodes)
    .join("rect")
    .attr("x", d => d.x0)
    .attr("y", d => d.y0)
    .attr("height", d => d.y1 - d.y0)
    .attr("width", d => d.x1 - d.x0);
}


document.addEventListener("DOMContentLoaded", () => {
  //chart()
  main()
})
