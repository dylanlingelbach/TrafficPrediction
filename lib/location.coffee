segments = require('../data/segments')

_ = require('underscore')

Number.prototype.toRad = () ->
  return this * Math.PI / 180

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
  R * c

gd = exports.getDistance
exports.findClosestSegment = (location) ->
  distance = segments.map (d) -> gd(location, d.start)
  minIndex = distance.indexOf(_.min(distance))
  return segments[minIndex]