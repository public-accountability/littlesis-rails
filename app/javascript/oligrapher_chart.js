import * as d3 from "d3"
import range from "lodash-es/range"
import sample from "lodash-es/sample"
import shuffle from "lodash-es/shuffle"

// const row = document.getElementById('oligrapher-chart-row')
// const width = document.getElementById('oligrapher-chart').offsetWidth

function transformData(data) {
  let d = data.map((x, i) => {
    x.parentId = 0
    x.value = sample(range(5, 21).concat([18, 18, 19, 19, 20, 20, 20, 20, 20])) // set values for d3 treemap tile size
    return x
  })

  d = shuffle(d)
  d.unshift({ id: 0, title: "root node", parentId: null })

  return d
}

function tree(data) {
  const height = 2000
  const width = document.getElementById("oligrapher-chart").offsetWidth

  const svg = d3
    .select("#oligrapher-chart")
    .append("svg:svg")
    .attr("width", width)
    .attr("height", height)

  const root = d3.stratify()(data)
  root.sum(x => x.value)
  //root.sum(() => 1) // equal size squares

  d3.treemap().size([width, height]).padding(8)(root)

  svg
    .selectAll("g.image")
    .data(root.leaves())
    .enter()
    .append("g")
    .attr("class", "image")
    .call(parent => parent.append("title").text(d => d.data.title))
    .call(parent => {
      parent
        .append("image")
        .attr("href", d => d.data.screenshot)
        .attr("title", d => d.data.title)
        .attr("x", d => d.x0)
        .attr("y", d => d.y0)
        .attr("width", d => d.x1 - d.x0)
        .attr("height", d => d.y1 - d.y0)
        .attr("preserveAspectRatio", "xMidYMid slice")
        .on("mouseover", (event, data) => {
          let rectId = "#rect-" + data.data.id
          d3.select(rectId).classed("hover", true)
          document.getElementById("oligrapher-chart-subheader").textContent = data.data.title
        })
        .on("mouseout", (event, data) => {
          let rectId = "#rect-" + data.data.id
          d3.select(rectId).classed("hover", false)
          document.getElementById("oligrapher-chart-subheader").textContent = ""
        })
        .on("click", (event, data) => {
          window.open(data.data.url, "_blank")
        })
    })

  svg
    .selectAll("g.rect")
    .data(root.leaves())
    .enter()
    .append("g")
    .attr("class", "rect")
    .call(parent => {
      parent
        .append("rect")
        .attr("id", d => "rect-" + d.data.id)
        .attr("x", d => d.x0)
        .attr("y", d => d.y0)
        .attr("width", d => d.x1 - d.x0)
        .attr("height", d => d.y1 - d.y0)
    })
}

document.addEventListener("DOMContentLoaded", () => {
  d3.json("/oligrapher.json").then(transformData).then(tree).catch(console.error)
})
