jade = require 'jade'

# Relies on existence of quip in middleware
# Relies on a response object
# Relies on correctly defining the path

module.exports = (res, fileName, data) ->
  filepath = __dirname + '/../content/' + fileName + '.jade'
  jade.renderFile filepath, data, (err, html) ->
    if err
      console.error 'Jade rendering failed.', err
      res.error()
    else
      res.ok(html)