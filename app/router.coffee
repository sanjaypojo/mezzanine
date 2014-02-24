renderJade = require './renderJade'

module.exports = (req, res, next) ->
  parsedUrl = req.url.split('/')
  switch req.method
    when 'GET'
      switch parsedUrl[1]
        when 'home'
          renderJade res, 'home', {}
        when '404'
          renderJade res, '404', {}
        else
          next()
    else
      next()
