# Requires D3

timeline = d3.select ".timeline"
palette = ["#336699", "#339966", "#993366", "#996633", "#669933", "#663399"]
dataPoints = []

for i in [1..100]
  dataPoints.push i

timeline.style "width", "100%"
  .style "height", "400px"

events = timeline.selectAll("circle").data(dataPoints).enter().append("circle")
  .attr "cx", (d, i) -> "#{10 + 10*i}"
  .attr "cy", (d, i) -> "#{100 + (d*d*d*d*d)%200}"
  .attr "r", "4"
  .style "fill", (d, i) -> palette[i%6]

counter = 0
presentValue = 0
randomValue = 0
speedStep = 0

d3.timer (e) ->
  counter += 1
  if counter is 1000
    counter = 1
  d3.selectAll("circle").attr "cy", (d, i) ->
    presentValue = parseInt d3.select(this).attr("cy")
    randomValue = 1 + Math.ceil 2*Math.random()
    speedStep = (d*d)%7
    ( presentValue + randomValue + speedStep)%400
  undefined
