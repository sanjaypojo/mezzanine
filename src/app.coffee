connect = require 'connect'
quip = require 'quip'
render = require 'rendered'

app = connect()

render.less(app, __dirname + '/styles/')

app
  .use connect.logger('small')
  .use quip
  .use (req, res, next) -> render.jade res, 'index', {}
  .listen 3000
