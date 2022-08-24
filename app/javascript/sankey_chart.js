/**
   Sankey Donation Graph

   see https://github.com/d3/d3-sankey
*/

import * as d3 from "d3"
import { sankey, sankeyLinkHorizontal } from 'd3-sankey'
import { find, each, chunk, map, remove, flatten, groupBy, sortBy, last, values, uniq } from 'lodash-es'
import pLimit from 'p-limit'
import { get } from './src/common/http.mjs'

const ENTITY_IDS = [13485, 34472, 117188, 13450, 13204 ]
// const ENTITY_IDS = [32580, 28778, 246695, 416193]

const fetchRelationships = id => get(`/api/entities/${id}/relationships`, { category_id: 5, per_page: 50, sort: 'amount' })

async function getEntities(ids) {
  if (ids.length <= 300) {
    let entities = await get('/api/entities', { ids: ids.join(",") })
    return entities.data
  } else if (ids.length <= 900) {
    const limit = pLimit(3)
    const requests = map(chunk(ids, 300), batch => limit(() => get('/api/entities', { ids: batch.join(",") })))
    const results = await Promise.all(requests)
    return flatten(map(results, r => r.data))
  } else {
    throw new Error(`cannot request ${ids.length} entities`)
  }
}

const formatMoney = m => m.toLocaleString('en-US', { style: 'currency', currency: 'USD' }).split('.')[0]

const calculateDisplay = function(entities, r) {
  let entity1 = find(entities, e => e.id === r.attributes.entity1_id)
  let entity2 = find(entities, e => e.id === r.attributes.entity2_id)
  return `${entity1.attributes.name} <- ${formatMoney(r.attributes.amount)} -> ${entity2.attributes.name}`
}

async function getRelationships(ids) {
  const limit = pLimit(2)
  const requests = map(ids, id => limit(() => fetchRelationships(id)))
  const results = await Promise.all(requests)
  const relationships = flatten(map(results, x => x.data))
  // Remove relationships with no amount
  remove(relationships, r => !Boolean(r.attributes.amount))
  // remove circular relationships
  remove(relationships, r => r.attributes.entity1_id === r.attributes.entity2_id)
  // limit to relationships where entity is the on the receiving end
  remove(relationships, r => !ids.includes(r.attributes.entity2_id))
  // keep only one relationship of the highest amount if multiple exist between two entities
  const grouped = values(groupBy(relationships, r => [r.attributes.entity1_id, r.attributes.entity2_id]))
  return flatten(map(grouped,rs => last(sortBy(rs, x => x.attributes.amount))))
}

async function relationshipNetwork(ids) {
  const relationships = await getRelationships(ids)
  const entityIds = uniq(flatten(map(relationships, r => [r.attributes.entity1_id, r.attributes.entity2_id])))
  const entities = await getEntities(entityIds)

  each(relationships, r => {
    r["source"] = r.attributes.entity1_id,
    r["target"] = r.attributes.entity2_id,
    r["value"] = r.attributes.amount,
    r["display"] = calculateDisplay(entities, r)
  })

  return { relationships, entities }
}

function createChart(data) {
  const margin = 10
  const offset = 10
  const leftOffset = 80
  const width = 1000  // - (margin * 2)
  const height = 3600 //  - (margin * 2)
  const extent = [[leftOffset, margin], [width - 200, height - (margin*2)]]

  const amounts = map(data.relationships, r => r.attributes.amount)

  const strokeWidthScale = d3.scaleLinear()
                  .domain([Math.min(...amounts), Math.max(...amounts)])
                  .range([2,6])

  // const strokeWidthScale = d3.scaleQuantize()
  //                 .domain([Math.min(...amounts), Math.max(...amounts)])
  //                 .range([1,2,3,4,5,6])

  const color = d3.scaleOrdinal(d3.schemeAccent)

  const tooltip = d3.select('body')
        .append('div')
        .attr('id', 'sankey-tooltip')
        // .style('opacity', 0)

  const svg = d3.select("#sankey-chart-svg")
        .append("svg")
        .attr("width", width)
        .attr("height", height)
        .attr("viewBox", [0, 0, width, height])
        .attr("style", "max-width: 100%; height: auto; height: intrinsic;")
        .append("g")
        .attr("transform",
              "translate(" + margin  + "," + margin + ")")

  const generator = sankey()
        .nodes(g => g.entities)
        .links(g => g.relationships)
        .nodeId(d => d.id)
        .extent(extent) // default =  [[0, 0], [1, 1]]
        .nodePadding(60)
        .iterations(7)  // default = 6
        .nodeWidth(30)
        // .nodePadding(300)       //

  const chart = generator(data) // { entities, relationships}

  window.sankeyChart = chart

  const link = svg
    .append("g")
    .selectAll('.sankey-links')
    .data(chart.links)
    .enter()
    .append("path")
    .attr("class", function(d) {
      return `sankey-link entity-${d.attributes.entity1_id} entity-${d.attributes.entity2_id}`
    })
    .attr("d", sankeyLinkHorizontal())
    .attr('pointer-events', 'visibleStroke')
    .attr("stroke-width", d =>  strokeWidthScale(d.value))
    .on("mouseover", function (e, d) {
      // tooltip.transition().duration(200).style("opacity", .9)
      tooltip
        .style("opacity", .9)
        .html(`<p>${d.display}</p>`)
        .style("left", (e.pageX + offset) + "px")
        .style("top", (e.pageY + offset) + "px")
    })
    .on("mouseout", function (e) {
      // tooltip.transition().duration(300).style("opacity", 0)
      tooltip.style("opacity", 0)
    })
    .on("mousemove", function (e) {
      d3.select('#sankey-tooltip')
        .style('left', (e.pageX + offset) + 'px')
        .style('top', (e.pageY + offset) + 'px')
    })

  const node = svg
    .append("g")
    .selectAll(".sankey-nodes")
    .data(chart.nodes)
    .enter()
    .append("text")
    .attr("class", "sankey-node")
    .text(d => d.attributes.name)
    .attr("x", d => {
      if (d.depth === 1) { // recipient
        return d.x0 + 10
      } else { // donor
        return d.x0 - leftOffset
      }
    })
    .attr("y", d => {
      if (d.depth === 1) { // recipient
        return d.y0
      } else { // donor
        return d.y0
      }
    })
    .on("click", (e, d) => window.open(d.links.self, '_blank'))
    .on("mouseover", function (e, d) {
      if (d.depth === 0) {
        document
        .querySelector('svg')
        .querySelectorAll(`path.entity-${d.id}`)
        .forEach(path => path.classList.add('sankey-link-hover'))
      }
    })
    .on("mouseout", function (e, d) {
      if (d.depth === 0) {
        document
        .querySelector('svg')
        .querySelectorAll(`path.entity-${d.id}`)
        .forEach(path => path.classList.remove('sankey-link-hover'))
      }
    })
}

async function main() {
  const network = await relationshipNetwork(ENTITY_IDS)
  console.log(network)
  createChart(network)
}

document.addEventListener("DOMContentLoaded", () => {
  main()
})
