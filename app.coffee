http = require 'http'
connect = require 'connect'
quip = require 'quip'
renderJade = require './app/renderJade'

router = require './app/router'

app = connect()

app
  .use connect.logger('tiny')
  .use connect.favicon(__dirname + '/public/fire.ico')
  .use quip
  .use connect.static(__dirname + '/public/')
  .use (req, res, next) -> router(req, res, next)

http.createServer(app).listen(3000)