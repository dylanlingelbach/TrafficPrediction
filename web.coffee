express = require("express")
app = express()
app.use(express.logger())
loc = require('./lib/location')
g = require('./lib/google')

app.get('/', (request, response) ->
  response.send('Hello!')
)

port = process.env.PORT || 5000
app.listen(port, ->
  console.log('Listening on ' + port)
)
