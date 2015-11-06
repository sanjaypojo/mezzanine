fs = require "fs"
connect = require "connect"
quip = require "quip"
serveStatic = require "serve-static"
morgan = require "morgan"
s = require "s-core"
transpile = require "transpile"
pr = s.parseRequest

app = connect()

page =
  home:
    html: ""
    path: "lkjansd7qwdAS"

transpile.publicPath = "#{__dirname}/public/"
transpile.less "#{__dirname}/styles/style.less"
transpile.cjsx "#{__dirname}/scripts/*.cjsx"
transpile.jade "#{__dirname}/markup/index.jade", {fileName: page.home.path}

transpile.watch "#{__dirname}/markup/index.jade", {}, (glob, path) ->
  transpile.jade glob, {fileName: page.home.path}

transpile.watch "#{__dirname}/scripts/*.cjsx", {}, (glob, path) ->
  transpile.cjsx path, {fileName: page.home.path}

transpile.watch "#{__dirname}/styles/*.less", {}, (glob, path) ->
  transpile.less "#{__dirname}/styles/style.less", {fileName: page.home.path}

serveFile = (res, pageName) ->
  if page[pageName]?.path
    if page[pageName]?.html?.length is 0
      page[pageName].html = fs.readFileSync "#{__dirname}/public/html/#{page[pageName]?.path}.html"
    res.ok page[pageName].html
  else
    res.notFound "Page Not Found!"

app
  .use morgan "dev"
  .use quip
  .use pr.url
  .use serveStatic "#{__dirname}/public/"
  .use (req, res, next) ->
    serveFile(res, "home")
  .listen 3000
