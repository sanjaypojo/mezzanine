connect = require 'connect'
quip = require 'quip'
render = require 's-rendered'
pr = require 's-parse-request'

app = connect()

render.public app, __dirname + '/public/'
render.less __dirname + '/styles/'
render.coffee __dirname + '/scripts/'

app
  .use connect.logger('small')
  .use quip
  .use pr.url
  .use connect.static __dirname + '/public/'
  .use (req, res, next) ->
    render.jade res, 'index', {host: req.query}
  .listen 3000
