fs = require "fs"
connect = require "connect"
quip = require "quip"
serveStatic = require "serve-static"
morgan = require "morgan"
s = require "s-core"
transpile = require "transpile"
pr = s.parseRequest
render = s.rendered
router = s.router

app = connect()

content = require "./content/content"

render.jadePath = "#{__dirname}/markup/"
transpile.publicPath = "#{__dirname}/public/"
transpile.less "#{__dirname}/styles/style.less"
transpile.cjsx "#{__dirname}/scripts/*.cjsx"

transpile.watch "#{__dirname}/scripts/*.cjsx", {}, (glob, path) ->
  transpile.cjsx path

transpile.watch "#{__dirname}/styles/*.less", {}, (glob, path) ->
  transpile.less "#{__dirname}/styles/style.less"

controller =
  home:
    get: (req, res, next, urlData) ->
      render.jade res, "index", {projects: content.projects}
  projects:
    get: (req, res, next, urlData) ->
      if content.projects[urlData.projects.page]
        render.jade(
          res, urlData.projects.page,
          content.projects[urlData.projects.page]
        )
      else
        next()

app
  .use morgan "dev"
  .use quip
  .use pr.url
  .use serveStatic "#{__dirname}/public/"
  .use router "/projects/:page", controller.projects, true
  .use router "/home", controller.home
  .use (req, res, next) ->
    if req.url is "/"
      res.redirect "/home"
    else
      res.notFound "Page not found"
  .listen 3000
