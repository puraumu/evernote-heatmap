# === Controller ===

rerender = () ->
  resetCoordinate()
  initializeConf()
  dynamicRenderer()

d3.select('#view-mode').on('change', () ->
  mode = this.value
  Conf.viewMode = 'day_view' if mode is 'day-mode'
  Conf.viewMode = 'week_view' if mode is 'week-mode'
  Conf.viewMode = 'month_view' if mode is 'month-mode'
  rerender()
)

d3.select('#yaxis').on('change', () ->
  yaxis = this.value
  Conf.yaxis = 'tag' if yaxis is 'tag'
  Conf.yaxis = 'notebook' if yaxis is 'notebook'
  rerender()
)

d3.select('#go').on('click', () ->
  year = d3.select('#year').node().value
  month = d3.select('#month').node().value
  Conf.start = new Date(year, month)
  rerender()
)

d3.select('#choose-color').on('change', () ->
  val = this.value
  d3.select('#right').select('svg').attr('class', "#{val}")
  d3.select('#sample').attr('class', "#{val}")
  Conf.color = val
)

mouseover = (p) ->
  right = d3.select('#right')[0][0]
  left = right.scrollLeft
  top  = right.scrollTop
  pop = d3.select('#pop')
  date = Conf.x_days[p.x]
  name = Conf.y_names[p.y]
  x = p.x * Posi.tile() + Posi.rowHead + Posi.rowHeadMargin - left
  y = p.y * Posi.tile() + Posi.dateMargin - Posi.cellSize

  pop.classed('hide', false)
  pop.style('left', "#{x}px").style('top', "#{y}px")
  pop.select('.date').text("#{date}")
  pop.select('.name').text("#{name}")
  pop.select('.value').text("#{p.z}")

mouseout = (p) ->
  pop = d3.select('#pop')
  pop.classed('hide', true)

# === /Controller ===

###
=== DATA ===
###
# all DATA should Global access. dynamicRenderer() and Controller would access
# following these variables.
# == static ==
month_format = d3.time.format("%Y-%m")
week_format = (date) ->
  out = Math.round((date.getDate() + 7 - date.getDay()) / 7)
  out = 1 if out is 0
  out = '1st' if out is 1
  out = '2nd' if out is 2
  out = '3rd' if out is 3
  out = "#{out}th" if out > 3
  "#{month_format date}-#{out}"
day_format = d3.time.format("%Y-%m-%d")

Disp = d3.select('#display')
# == /static ==

# -- dynamic
X_disp = Disp
Y_disp = Disp
Cells = Disp

# -- dynamic
Conf =
  start: do ->
    latest = new Date().getTime()
    half = 1 * 30 * 24 * 60 * 60 * 1000 # 30 days * 24h * 60min * 60sec
    new Date(latest - half)
  end: new Date()
  color: "YlGn"
  # color: "PuBu"
  json: []
  x_days: []
  y_names: []
  # yaxis: "notebook"
  yaxis: "tag"
  viewMode: 'day_view' # day_view => .day_view
  # viewMode: 'week_view' # week_view => .week_view
  # viewMode: 'month_view' # month_view => .month_view

# -- dynamic
Posi =
  dateMargin: 70
  rowHeadMargin: 7
  rowHead: 100
  width: 940
  displayWidth: () ->
    Posi.width - Posi.rowHead
  cellSize: 18
  cellMargin: 2
  tile: () ->
    Posi.cellSize + Posi.cellMargin

# -- dynamic
initializeConf = () ->
  sta = Conf.start.getTime()
  end = Conf.end.getTime()
  # sta = Math.round sta
  # end = Math.round end

  if Conf.yaxis is 'notebook'
    foo = {}
    for item in Conf.json
      time = item.created
      if sta < time and time < end
        foo[item.notebook] = null
    Conf.y_names = Object.keys(foo).sort()

  if Conf.yaxis is 'tag'
    foo = {}
    for item in Conf.json
      time = item.created
      if sta < time and time < end
        for tag in item.tags
          foo[tag] = null
    Conf.y_names = Object.keys(foo).sort()

  if Conf.viewMode is 'day_view'
    Conf.x_days = d3.time.days(Conf.start, Conf.end).map((d) -> day_format d)
  if Conf.viewMode is 'week_view'
    Conf.x_days = d3.time.weeks(Conf.start, Conf.end).map((d) -> week_format d)
  if Conf.viewMode is 'month_view'
    Conf.x_days = d3.time.months(Conf.start, Conf.end).map((d) -> month_format d)

  left = Disp.select('#left').append('svg')
    .attr('width', Posi.rowHead)
    .attr('height', Conf.y_names.length * Posi.tile() + Posi.dateMargin)
  right = Disp.select('#right').append('svg')
    .attr('width', () ->
      width = Conf.x_days.length * Posi.tile() + Posi.tile() * 2
      if width < Posi.displayWidth()
        return Posi.displayWidth() - Posi.rowHeadMargin
      else
        return width )
    .attr('height', Conf.y_names.length * Posi.tile() + Posi.dateMargin)
    .attr('class', "#{Conf.color}")

  right.append('rect')
    .attr('x', 0)
    .attr('y', Posi.dateMargin)
    .attr('height', Conf.y_names.length * Posi.tile())
    .attr('width', Conf.x_days.length * Posi.tile())
    .attr('class', "q0-9")

  X_disp = right.append('g')
    .attr('id', 'X-disp')
    .attr("transform", "translate(#{0}, #{Posi.dateMargin})")
  Y_disp = left.append('g')
    .attr('id', 'Y-disp')
    .attr("transform", "translate(#{Posi.rowHead}, #{Posi.dateMargin + Posi.cellSize - 3})")
  Cells = right.append('g')
    .attr('id', 'Cells')
    .attr("transform", "translate(#{0}, #{Posi.dateMargin})")

console.log Conf
# return false
###
=== /DATA ===
###

###
=== Renderer ===
###

resetCoordinate = () ->
  Disp.select('#left').select('svg').remove()
  Disp.select('#right').select('svg').remove()
  d3.select('#sample').select('g').remove()

dynamicRenderer = () ->
  ###
  === Positioning ===
  ###
  # -- sample color
  colorbrewer = d3.range(9)
  sample = d3.select('#sample')
    .attr('class', "#{Conf.color}")
    .attr('width', colorbrewer.length * Posi.tile())
    .attr('height', Posi.tile() * 1.0)
  sample.append('g').selectAll('rect')
      .data(colorbrewer)
    .enter().append('rect')
      .attr('x', (d) -> d * Posi.tile())
      .attr('y', 0)
      .attr('height', Posi.cellSize)
      .attr('width', Posi.cellSize)
      .attr('class', (d) -> "q#{d}-9")

  # dynamic local settings
  # -- dynamic
  date_list = Conf.x_days
  name_list = Conf.y_names
  usm_width = 1
  matrix = []

  if Conf.viewMode is 'day_view'
    format = day_format
  if Conf.viewMode is 'week_view'
    format = week_format
  if Conf.viewMode is 'month_view'
    format = month_format

  for item,i in name_list
    matrix[i] = d3.range(date_list.length).map((x) -> {x:x, y:i, z:0})

  if Conf.yaxis is 'notebook'
    for item in Conf.json
      f = format new Date(item.created)
      x = date_list.indexOf f
      if x is -1
        continue
      y = name_list.indexOf item.notebook
      if y is -1
        continue
      matrix[y][x].z += 1

  if Conf.yaxis is 'tag'
    for item in Conf.json
      f = format new Date(item.created)
      x = date_list.indexOf f
      if x is -1
        continue
      for tag in item.tags
        y = name_list.indexOf tag
        if y is -1
          continue
        matrix[y][x].z += 1

  row = Cells.selectAll('g')
      .data(matrix)
    .enter().append('g')
      .attr("transform", (d,i) -> "translate(0, #{i * Posi.tile()})")

  # X ->
  row.append('line')
    .attr('x1', 0)
    .attr('x2', () -> Posi.tile() * date_list.length - 1)
    .attr('y1', Posi.cellSize + usm_width * 0.5)
    .attr('y2', Posi.cellSize + usm_width * 0.5)
    .attr('stroke', 'deepskyblue')
    .attr('stroke-width', usm_width)
  row.append('line')
    .attr('x1', 0)
    .attr('x2', () -> Posi.tile() * date_list.length - 1)
    .attr('y1', (Posi.cellSize + usm_width) + usm_width * 0.5)
    .attr('y2', (Posi.cellSize + usm_width) + usm_width * 0.5)
    .attr('stroke', 'white')
    .attr('stroke-width', usm_width)

  # Y |||
  X_disp.selectAll('.shadow')
      .data(d3.range(date_list.length + 1))
    .enter().append('line')
      .attr('class', 'shadow')
      .attr('x1', (d) -> d * Posi.tile() - usm_width * 1.5)
      .attr('x2', (d) -> d * Posi.tile() - usm_width * 1.5)
      .attr('y1', 0)
      .attr('y2', (d) -> Posi.tile() * Conf.y_names.length - 1)
      .attr('stroke', 'deepskyblue')
      .attr('stroke-width', usm_width)
  Cells.selectAll('.back')
      .data(d3.range(date_list.length + 1))
    .enter().append('line')
      .attr('class', 'back')
      .attr('x1', (d) -> (d * Posi.tile() + usm_width) - usm_width * 1.5)
      .attr('x2', (d) -> (d * Posi.tile() + usm_width) - usm_width * 1.5)
      .attr('y1', 0)
      .attr('y2', (d) -> Posi.tile() * Conf.y_names.length - 1)
      .attr('stroke', 'white')
      .attr('stroke-width', usm_width)

  X_disp.selectAll('g')
      .data(date_list)
    .enter().append('g')
      .attr("transform", (d,i) -> "translate(#{Posi.tile() * i + 10}, 0)")
      .append('text')
        .attr("transform", "translate(0, 0)rotate(-50)")
        .attr('fill', "#333")
        .style('font-size', 13)
        .text((d) -> d)

  Y_disp.selectAll('text')
      .data(name_list)
    .enter().append('text')
      .attr('y', (d,i) -> Posi.tile() * i)
      .attr('text-anchor', "end")
      .attr('fill', "#333")
      .style('font-size', 13)
      .text((d) -> d)

  if Conf.viewMode is 'day_view'
    domain = [0,10]
  if Conf.viewMode is 'week_view'
    domain = [0,20]
  if Conf.viewMode is 'month_view'
    domain = [0,50]
  scale_down = (n) ->
    return 0 if n is 0
    linear = d3.scale.linear()
      .domain(domain)
      .range([1,8])
    out = linear(n)
    if out > 8
      return 8
    else
      return Math.round out
  row.each((d) ->
    d3.select(this).selectAll('rect')
        .data(d.filter((j) -> j.z > 0))
      .enter().append('rect')
        .attr('class', (d) -> "#{Conf.viewMode} q#{scale_down d.z}-9")
        .attr('height', Posi.cellSize)
        .attr('width', Posi.cellSize)
        .attr('x', (d,i) -> Posi.tile() * d.x)
        .attr('y', 0) )

  ###
  === /Positioning ===
  ###
  ###
  === Coloring ===
  ###

  # TODO
  # Y
  # -- dynamic
  # Controller
  Cells.selectAll('rect')
    .on('mouseover', mouseover)
    .on('mouseout', mouseout)

  ###
  === /Coloring ===
  ###
###
=== /Renderer ===
###

###
=== Only Once, Initialize ===
###

year_selection = () ->
  this_year = new Date().getFullYear()
  day_list = []
  for item in Conf.json
    day_list.push item.created
  oldest = day_list.sort()[0]
  year_range = this_year - new Date(oldest).getFullYear() + 1
  year_range = d3.range(year_range).map((i) -> this_year - i)
  d3.select('#year').selectAll('option')
      .data(year_range)
    .enter().append('option')
      .attr('value', (d) -> d)
      .text((d) -> d)

json_url = "/static/evernote.json"
d3.json json_url, (json) ->
  Conf.json = json
  initializeConf()
  year_selection()
  dynamicRenderer()

###
=== /Only Once, Initialize ===
###
