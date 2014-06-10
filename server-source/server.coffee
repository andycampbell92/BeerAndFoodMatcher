# Express to host our index file
express = require 'express'
restify = require 'restify'
mongojs = require 'mongojs'
Q 		= require 'q'

class Server
	constructor: ->
		@_setupHTMLServer()
		@_setupRESTServer()
		@_setupDatabase()

	_setupHTMLServer: ->
		# Host folder containing index.html
		@webServer = express()
		@webServer.use express.static __dirname + '/'

	_getFirstLevelData: (req, res, next) =>
		res.header 'Content-Type', 'json'
		@db.styles.find (err, docs) ->
		    if err
		    	res.send(400, err)
		    else if docs.length == 0
		    	res.send(400, "No Styles found")
		    else
		    	res.send JSON.stringify docs

	_getEntryById: (id) ->
		deferred = Q.defer()
		if typeof id == 'string'
			id = mongojs.ObjectId id
		if typeof id != 'object' or id == null
			deferred.reject 'Type of id must be string or ObjectId'

		else
			@db.styles.findOne {_id:id}, (err, doc) ->
				if err
					deferred.reject err
				else if doc == null
					deferred.reject "Document with the ID " + id.toString() + " does not exist"
				else
					# If there were no errors call the callback with the document
					deferred.resolve doc

		return deferred.promise




	_setupRESTServer: ->
		# Host our rest server
		@RESTServer = restify.createServer {name: 'BeerAndFoodMatcherV1.0'}
		@RESTServer.get '/getData', @_getFirstLevelData

	_setupDatabase: ->
		@db = mongojs 'beerandfooddb', ['styles']

	start: ->
		@webServer.listen 80
		@RESTServer.listen 8080

module.exports = Server