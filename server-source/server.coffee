# Express to host our index file
express = require 'express'
restify = require 'restify'
fs 		= require 'fs'

class Server
	constructor: ->
		@_setupHTMLServer()
		@_setupRESTServer()

	_setupHTMLServer: ->
		# Host folder containing index.html
		@webServer = express()
		@webServer.use express.static __dirname + '/'

	_getFirstLevelData: (req, res, next) ->
		res.header 'Content-Type', 'json'
		file = __dirname + '/styles.json'
		fs.readFile file, 'utf8', (err, data) ->
			res.send data

	_setupRESTServer: ->
		# Host our rest server
		@RESTServer = restify.createServer {name: 'BeerAndFoodMatcherV1.0'}
		@RESTServer.get '/getData', @_getFirstLevelData

	start: ->
		@webServer.listen 80
		@RESTServer.listen 8080

server = new Server()
server.start()