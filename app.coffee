http = require 'http'
connect = require 'connect'
quip = require 'quip'

router = require './app/router'

app = connect()

app
  .use connect.logger('tiny')
  .use quip
  .use connect.static(__dirname + '/public/')
  .use (req, res, next) ->
    router(req, res, next)
  .use (req, res, next) ->
    res.redirect '/404'

http.createServer(app).listen(3000)