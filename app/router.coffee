renderJade = require './renderJade'
moment = require 'moment'

navPages =
  home:
    name: 'Home'
    url: '/home'
  resume:
    name: 'Resume'
    url: '/resume'
  contact:
    name: 'Contact Me'
    url: '/contact'


timeline =
  # event4:
  #   startDate: moment("2013-10-23")
  #   endDate: moment("2014-01-10")
  #   organisation: "Magnetworks"
  #   city: "Bangalore"
  #   what: "Full Stack Development Project"
  event4:
    startDate: moment("2013-10-18")
    endDate: moment()
    organisation: "Softrade"
    city: "Bangalore"
    what: "Project Lead"
  event3:
    startDate: moment("2012-06-17")
    endDate: moment("2013-10-17")
    organisation: "Deutsche Bank"
    city: "Mumbai/Singapore"
    what: "Analyst, Commodities Sales Asia-Pacific"
  event2:
    startDate: moment("2008-08-01")
    endDate: moment("2012-06-01")
    organisation: "IIT Madras"
    city: "Chennai"
    what: "B.Tech in Engineering Physics"
  event1:
    startDate: moment("1994-06-01")
    endDate: moment("2008-06-01")
    organisation: "NAFL"
    city: "Bangalore"
    what: "School"

module.exports = (req, res, next) ->
  parsedUrl = req.url.split('/')
  switch req.method
    when 'GET'
      switch parsedUrl[1]
        when 'home'
          renderJade res, 'home', {pages: navPages}
        when 'resume'
          renderJade res, 'resume', {pages: navPages, moment: moment, timeline: timeline}
        else
          renderJade res, '404', {pages: navPages}
    else
      renderJade res, '404', {pages: navPages}
