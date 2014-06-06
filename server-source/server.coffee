# Express to host our index file
express = require 'express'

class Server
	constructor: ->
		@_setupHTMLServer()

	_setupHTMLServer: ->
		@app = express()
		@app.use express.static __dirname + '/'

	start: ->
		@app.listen 80

server = new Server()
server.start()