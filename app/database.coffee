mongoose = require 'mongoose'


exports.models = () ->
  mongoose.connect('mongodb://localhost/test')
  db = mongoose.connection
  db.on 'error' console.error.bind(console, 'connection error:')
  db.once 'open' () ->
    eventSchema = mongoose.Schema(

    )
