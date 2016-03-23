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
  dubdenApi:
    post: (req, res, next, urlData) ->
      console.log req?.file?.path
      console.log req?.body?.password
      res.headers "Access-Control-Allow-Origin": "http://sanjaypojo.github.io"

      apiError = (errorMessage) ->
        console.log errorMessage
        res.forbidden("Image upload failed. Contact @sanjaypojo")

      # Check image code and password
      if req?.body?.password is "hungryPanda" && urlData.reykjavik.code in ["carousel-1", "carousel-2", "carousel-3", "carousel-5", "carousel-5", "carousel-6"]
        # Read the temp file
        fs.exists req?.file?.path, (exists)->
          if !exists
            apiError("Uploaded file could not be found")
          else
            imageFile = fs.readFileSync req?.file?.path
            fs.exists "#{__dirname}/public/dubden/", (dirExists) ->
              if !dirExists
                fs.mkdirSync "#{__dirname}/public/dubden/"
              fs.writeFile "#{__dirname}/public/dubden/#{urlData.reykjavik.code}.png", imageFile, (err) ->
                if err
                  apiError("Unable to write file to public: #{err}")
                else
                  res.ok("Image upload successful")
      else
        res.forbidden("Incorrect password. Contact @sanjaypojo")
        return


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

# Image uploads for dubden
dubdenUpload = pr.upload({dest: "#{__dirname}/private/dubden/"})

app
  .use morgan "dev"
  .use quip
  .use pr.url
  .use serveStatic "#{__dirname}/public/"
  .use (req, res, next) ->
    incomingIP = req?.headers?["x-forwarded-for"] || req?.connection?.remoteAddress || req?.socket?.remoteAddress || req?.connection?.socket?.remoteAddress
    incomingUrl = "#{req?.headers?.host}#{req.url}"
    validIP = ///
      ^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)
      \.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)
      \.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)
      \.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$
    ///
    if validIP.test(incomingIP) && incomingUrl.indexOf("uptime") is -1
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
  .use "/api/dubden-uploads/reykjavik/", dubdenUpload.single("image")
  .use router "/api/dubden-uploads/reykjavik/:code", controller.dubdenApi, true
  .use router "/projects/:page", controller.projects, true
  .use router "/timeline", controller.timeline
  .use (req, res, next) ->
    # Custom routes
    if req.url is "/"
      render.jade res, "index", {projects: content.projects}
    else if req.url is "/media-lab-portfolio"
      res.redirect "/"
    else if req.url is "/sitepoint"
      res.redirect "/"
    else
      render.jade res.notFound(), "404"
  .listen 3000
