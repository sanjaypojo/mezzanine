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
Tracker = s.tracker
reqwest = require "request"

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
  timeline:
    get: (req, res, next, urlData) ->
      render.jade res, "timeline", {events: content.timeline}
  projects:
    get: (req, res, next, urlData) ->
      if content.projects[urlData.projects.page]
        render.jade(
          res, urlData.projects.page,
          content.projects[urlData.projects.page]
        )
      else
        next()

tracker = new Tracker(
  slack:
    enabled: true
    webhookUrl: "https://hooks.slack.com/services/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"
    messageFormat: [
      {key: "org", label: "Organisation"}
      {key: "ip", label: "IP Address"}
      {key: "location", label: "Location"}
    ]
  project:
    name: "mezzanine"
)

app
  .use morgan "dev"
  .use quip
  .use pr.url
  .use serveStatic "#{__dirname}/public/"
  .use (req, res, next) ->
    incomingIP = req?.headers?["x-forwarded-for"] || req?.connection?.remoteAddress || req?.socket?.remoteAddress || req?.connection?.socket?.remoteAddress
    validIP = ///
      ^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)
      \.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)
      \.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)
      \.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$
    ///
    if validIP.test(incomingIP)
      incomingUrl = "#{req?.headers?.host}#{req.url}"
      reqwest.get "http://ipinfo.io/#{incomingIP}/json", (err, response, body) ->
        if !err
          data = JSON.parse body
          tracker.event(
            "Page visit: #{incomingUrl}",
            ip: incomingIP
            org: data?.org
            location: "#{data?.city}, #{data?.region}, #{data?.country}"
          )
    next()
  .use router "/projects/:page", controller.projects, true
  .use router "/home", controller.home
  .use router "/timeline", controller.timeline
  .use (req, res, next) ->
    if req.url is "/" || req.url is "/media-lab-portfolio"
      res.redirect "/home"
    else
      res.notFound "Page not found"
  .listen 3000
