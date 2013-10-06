_ = require('underscore')

location = require('./location')

exports.getSteps = (directions) ->
  _.flatten(directions.routes.map (route) ->
    route.legs.map (leg) ->
      leg.steps
    )

exports.getStreet = (step) ->
  instructions = step.html_instructions
  street_match = /ont?o?\s+\<b\>([\s|\w+]+)\<\/b\>/
  match = street_match.exec(instructions)
  if match
    street = match[1]
    street = street.replace('E ', '')
    street = street.replace('W ', '')
    street = street.replace('S ', '')
    street = street.replace('N ', '')
    street = street.replace(' St', '')
    street = street.replace(' Rd', '')
    street = street.replace(' Dr', '')
    street = street.replace(' Ct', '')
    street = street.replace(' Ave', '')
    street = street.replace('Lower ', '')
    street = street.replace(' ', '')
    street

gs = exports.getStreet

exports.getSegments = (steps) ->
  steps.map (step) ->
    street = gs(step)
    direction = location.findDirection(step.start_location, step.end_location)
    segment = location.findClosestSegment(street, direction, step.start_location)
    {segments: [segment], step: step}


