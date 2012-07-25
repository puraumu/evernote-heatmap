var pow = d3.scale.pow()
  .domain([.2, 1])
  .range(d3.range(8));

var lin = d3.scale.linear()
  .domain([0,50])
  .range([1,8]);
  // .range(d3.range(9));

var log = d3.scale.log()
  .domain([0,10])
  .range(d3.range(3));

var color = d3.scale.linear()
    .domain([0, 2])
    .range(["white", "green"]);

