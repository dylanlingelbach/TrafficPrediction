segments = require('../data/segments')

_ = require('underscore')

Number.prototype.toRad = () ->
  return (this * Math.PI) / 180

Number.prototype.toDeg = () ->
   return (this * 180) / Math.PI

# Get the distance between two lat/long pairs
# Use the Great Circle method (http://en.wikipedia.org/wiki/Great-circle_distance)
exports.getDistance = (start, end) ->
  R = 6371 # Earth's radius (km)
  startLat = parseFloat(start.lat)
  startLng = parseFloat(start.lng)
  endLat = parseFloat(end.lat)
  endLng = parseFloat(end.lng)
  dLat = (endLat-startLat).toRad()
  dLon = (endLng-startLng).toRad()

  a = Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(startLat.toRad()) * Math.cos(endLat.toRad())
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  R * c * 1000

gd = exports.getDistance

findSegment = (street, direction, location, kind) ->
  streetSegments = segments.filter (s) -> s.street == street && [].concat(direction || []).indexOf(s.direction) != -1
  distance = streetSegments.map (d) -> gd(location, d[kind])
  minIndex = distance.indexOf(_.min(distance))
  return streetSegments[minIndex]

exports.findPriorSegment = (street, direction, location) ->
  findSegment(street, direction, location, 'end')

exports.findClosestSegment = (street, direction, location) ->
  findSegment(street, direction, location, 'start')

exports.needPriorSegment = (step, closestSegment) ->
  segmentLength = gd(closestSegment.start, closestSegment.end)
  stepStartToSegmentEndLength = gd(step.start_location, closestSegment.end)
  segmentLength < stepStartToSegmentEndLength

exports.findDirection = (start, end) ->
  startLat = parseFloat(start.lat)
  startLng = parseFloat(start.lng)
  endLat = parseFloat(end.lat)
  endLng = parseFloat(end.lng)
  dLng = (endLng - startLng).toRad()
  startLat = startLat.toRad()
  startLng = startLng.toRad()
  endLat = endLat.toRad()
  endLng = endLng.toRad()
  y = Math.sin(dLng) * Math.cos(endLat)
  x = Math.cos(startLat)*Math.sin(endLat) - Math.sin(startLat)*Math.cos(endLat)*Math.cos(dLng)
  bearing = Math.atan2(y, x).toDeg()
  bearing = (bearing + 360) % 360
  if bearing >= 337.5 || bearing <= 22.5
    return 'NB'
  if bearing > 22.5 && bearing < 67.5
    return ['NE', 'NB', 'EB']
  if bearing >= 67.5 && bearing <= 112.5
    return 'EB'
  if bearing > 112.5 && bearing < 157.5
    return ['SE', 'SB', 'EB']
  if bearing >= 157.5 && bearing <= 202.5
    return 'SB'
  if bearing > 202.5 && bearing < 247.5
    return ['SW', 'SB', 'WB']
  if bearing >= 247.5 && bearing <= 292.5
    return 'WB'
  if bearing > 292.5 && bearing < 337.5
    return ['NW', 'NB', 'WB']


