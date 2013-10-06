_ = require('underscore')

location = require('./location')
googlemaps = require('googlemaps')

getSteps = (directions) ->
  _.flatten(directions.routes.map (route) ->
    route.legs.map (leg) ->
      leg.steps
    )
exports.getSteps = getSteps

getStreet = (step) ->
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
exports.getStreet = getStreet

getSegments = (steps) ->
  steps.map (step) ->
    street = getStreet(step)
    direction = location.findDirection(step.start_location, step.end_location)
    segments = []
    segment = _.clone(location.findClosestSegment(street, direction, step.start_location))
    if segment
      remainingMeters = step.distance.value
      if location.needPriorSegment(step, segment)
        priorSegment = _.clone(location.findPriorSegment(street, direction, segment.start))
        if priorSegment
          distance = location.getDistance(step.start_location, priorSegment.end)
          remainingMeters -= distance
          priorSegment.metersOnSegment = distance
          segments.push priorSegment

      if !priorSegment
        distance = location.getDistance(step.start_location, segment.end)
        segment.metersOnSegment = _.min([distance, remainingMeters])
        remainingMeters -= distance
        segments.push segment
      else
        segment = priorSegment

      while remainingMeters > 0
        segment = _.clone(location.findClosestSegment(street, direction, segment.end))
        if segment
          distance = location.getDistance(segment.start, segment.end)
          segment.metersOnSegment = _.min([distance, remainingMeters])
          remainingMeters -= segment.metersOnSegment
          segments.push segment
        else
          break

    {segments: segments, step: step}
exports.getSegments = getSegments

exports.getDirections = (origin, destination, callback) ->
  cb = (error, data) ->
    if !error
      steps = getSteps(data)
      directions = getSegments(steps)
      callback(null, directions)
    else
      callback(error, null)
  #                                              #sensor, #mode, #waypoints, #alternatives, #avoid
  googlemaps.directions(origin, destination, cb, false,   null,  null,       null,          'highways')
