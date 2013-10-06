express = require("express")
app = express()
app.use(express.logger())
g = require('./lib/google')
nodedump = require('nodedump')

app.get('/', (request, response) ->
  g.getDirections('401 E Ontario St 60611', '5700 South Cicero Avenue, Chicago Midway International Airport, Chicago, IL 60638, USA', (error, data) ->
    if error
      response.send('Error')
    else
      response.send(nodedump.dump(data))
  )
)

port = process.env.PORT || 5000
app.listen(port, ->
  console.log('Listening on ' + port)
)
