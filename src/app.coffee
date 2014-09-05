connect = require 'connect'
quip = require 'quip'
render = require 'rendered'
pr = require 'parse-request'

app = connect()

render.less(app, __dirname + '/styles/')

app
  .use connect.logger('small')
  .use quip
  .use pr.url
  .use (req, res, next) ->
    console.log req.url
    console.log req.query.hello
    render.jade res, 'index', {host: req.query}
  .listen 3000
