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

	_getFirstLevelDataREST: (req, res, next) =>
		res.header 'Content-Type', 'json'
		res.header "Access-Control-Allow-Origin", "*"
		res.header "Access-Control-Allow-Headers", "X-Requested-With"
		@db.nodes.find {superNode:true}, (err, docs) =>
		    if err
		    	res.send 400, err 
		    else if docs.length == 0
		    	res.send 400, "No Styles found"
		    else
		    	counter = docs.length
		    	resolvedDocs = []
		    	for doc in docs
		    		if doc.links.length == 0
		    			resolvedDocs.push doc
		    			counter--
		    		else
			    		@_resolveLinks(doc).then (resolvedDoc) ->
			    			resolvedDocs.push resolvedDoc
			    			counter--
			    			if counter == 0
			    				res.send JSON.stringify resolvedDocs
		    			, (err) ->
		    				res.send 400, "Failed to resolve links"
		    	if counter == 0
		    		res.send JSON.stringify resolvedDocs

	_getDataByIdREST: (req, res, next) =>
		res.header 'Content-Type', 'json'
		res.header "Access-Control-Allow-Origin", "*"
		res.header "Access-Control-Allow-Headers", "X-Requested-With"
		@_getEntryById(req.params.id)
		.then (doc) => 
			if doc.links.length == 0
				res.send 200, JSON.stringify doc
			else 
				@_resolveLinks(doc)
				.then (doc) ->
					res.send 200, JSON.stringify doc
				, (err) ->
					res.send 400, err
		, (err) ->
			res.send 400, err


	_getEntryById: (id) ->
		deferred = Q.defer()
		if typeof id == 'string'
			try
				id = mongojs.ObjectId id
			catch err
				deferred.reject err
			
		if typeof id != 'object' or id == null
			deferred.reject 'Type of id must be string or ObjectId'

		else
			@db.nodes.findOne {_id:id}, (err, doc) ->
				if err
					deferred.reject err
				else if doc == null
					deferred.reject "Document with the ID " + id.toString() + " does not exist"
				else
					# If there were no errors call the callback with the document
					deferred.resolve doc

		return deferred.promise

	_resolveLinks: (doc) ->
		deferred = Q.defer()
		@_getListOfEntriesById(doc.links).then (links) ->
			doc.links = links
			deferred.resolve doc
		, (err) ->
			deferred.reject err
		return deferred.promise

	_getListOfEntriesById: (idList) ->
		deferred = Q.defer()
		if not Array.isArray idList
			deferred.reject 'The id list given was not an array'
		else if idList.length == 0
			deferred.reject 'The id list must not be empty'
		else
			convertedList = []
			try
				for id in idList
					if typeof id == 'string'
						id = mongojs.ObjectId id

					if typeof id != 'object' or id == null
						throw 'One or more of the ID\'s provided was not a string/objectId or was null'
					else
						convertedList.push id
			catch err
				deferred.reject err

			@db.nodes.find {_id: {$in: convertedList}}, (err, docs) ->
				if err
					deferred.reject err
				else if docs.length != convertedList.length
					deferred.reject((convertedList.length - docs.length) + " of the ID's provided could not be found in the database")
				else
					deferred.resolve docs

		return deferred.promise



	_setupRESTServer: ->
		# Host our rest server
		@RESTServer = restify.createServer {name: 'BeerAndFoodMatcherV1.0'}
		@RESTServer.get '/getData', @_getFirstLevelDataREST
		@RESTServer.get '/getData/:id', @_getDataByIdREST

	_setupDatabase: ->
		@db = mongojs 'beerandfooddb', ['nodes']

	start: ->
		@webServer.listen 80
		@RESTServer.listen 8080

module.exports = Server