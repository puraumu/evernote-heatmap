// DATA
function monthPath(t0) {
  var t1 = new Date(t0.getFullYear(), t0.getMonth() + 1, 0),
      d0 = +day(t0), w0 = +week(t0),
      d1 = +day(t1), w1 = +week(t1);
  return "M" + (w0 + 1) * cellSize + "," + d0 * cellSize
      + "H" + w0 * cellSize + "V" + 7 * cellSize
      + "H" + w1 * cellSize + "V" + (d1 + 1) * cellSize
      + "H" + (w1 + 1) * cellSize + "V" + 0
      + "H" + (w0 + 1) * cellSize + "Z";
}

var margin = {top: 19, right: 20, bottom: 20, left: 19},
    width = 960 - margin.right - margin.left, // width
    height = 136 - margin.top - margin.bottom, // height
    cellSize = 17; // cell size

// NG
//   d3.time
var day = d3.time.format("%w"),
    week = d3.time.format("%U"),
    percent = d3.format(".1%"),
    format = d3.time.format("%Y-%m-%d");

var color = d3.scale.quantize()
    .domain([-.05, .05])
    .range(d3.range(9));
// End of DATA

// Init?
// NG => clear?
//   .data() ok
//   .range() ok
var svg = d3.select("#display").selectAll("svg")
    .data(d3.range(2008, 2011))
  .enter().append("svg")
    .attr("width", width + margin.right + margin.left)
    .attr("height", height + margin.top + margin.bottom)
    .attr("class", "RdYlGn")
  .append("g")
    .attr("transform", "translate(" +
        (margin.left + (width - cellSize * 53) / 2) + "," +
        (margin.top + (height - cellSize * 7) / 2) + ")");

// ign
// svg.append("text")
    // .attr("transform", "translate(-6," + cellSize * 3.5 + ")rotate(-90)")
    // .attr("text-anchor", "middle")
    // .text(String);

// Positioning
// NG => clear?
//   .d3.time.days() ok
//   .datum() ok
var rect = svg.selectAll("rect.day")
    .data(function(d) { return d3.time.days(new Date(d, 0, 1), new Date(d + 1, 0, 1)); })
  .enter().append("rect")
    .attr("class", "day")
    .attr("width", cellSize)
    .attr("height", cellSize)
    .attr("x", function(d) { return week(d) * cellSize; })
    .attr("y", function(d) { return day(d) * cellSize; })
    .datum(format);

// ign
// rect.append("title")
    // .text(function(d) { return d; });

// outer line?
// NG => clear?
//   .enter() ok
svg.selectAll("path.month")
    .data(function(d) { return d3.time.months(new Date(d, 0, 1), new Date(d + 1, 0, 1)); })
  .enter().append("path")
    .attr("class", "month")
    .attr("d", monthPath);

// Coloring 17px tiles
// NG => clear?
//   .key() ok
//   rollup() ok
//   .nest() ok
//   .filter() ok
d3.csv("./static/dji.csv", function(csv) {
  // using Date, Open, Close from csv
  var data = d3.nest()
    .key(function(d) { return d.Date; })
    .rollup(function(d) { return (d[0].Close - d[0].Open) / d[0].Open; })
    .map(csv);
console.log(data);

  rect.filter(function(d) { return d in data; })
      .attr("class", function(d) { return "day q" + color(data[d]) + "-9"; })
    .select("title")
      .text(function(d) { return d + ": " + percent(data[d]); });
});
/*
 * */
