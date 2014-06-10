should 	= require 'should'
request = require 'supertest'
Q 		= require 'q'
Server 	= require '../server'
mongojs = require 'mongojs'

# Test for our REST services
describe 'RestSevice', ->
	before (done) ->
		server = new Server()
		server.start()
		@url = "http://localhost:8080"

		# A test to check if a 
		@checkEntryFormatPostJSON = (entry) ->
			# Our id should be a string
			entry.should.have.property('_id').with.type 'string'
			# Beer names should be strings
			entry.should.have.property('name').with.type 'string'
			# Our super node or not identifyer should be boolean
			entry.should.have.property('superNode').with.type 'boolean'
			# Our beer type should be string
			entry.should.have.property('type').with.type 'string'
			# Our links to other nodes should be an array
			entry.should.have.property 'links'
			Array.isArray(entry.links).should.equal true

		@checkEntryFormatPreJSON = (entry) ->
			# When we stringify and parse our objects our ID will become a string
			# Because of this we need two seperate check format functions
			entry._id = entry._id.toString()
			@checkEntryFormatPostJSON entry

		done()

	describe 'First level of beer styles and links', ->
		address = '/getData'
		it 'Should have a correctly structured json object', (done) ->
			request @url
				.get address
				.expect('Content-Type', /json/)
				.expect(200)
				.end (err, res) =>
					responseData = JSON.parse res.body
					# This will throw if request fails or expects are not fufilled
					if err
						throw err
					# We should have data
					responseData.length.should.not.equal 0
					for el in responseData
						@checkEntryFormatPostJSON el

					done()

	describe 'Getting a database entry (beer, food, beer style) by an ID', ->
		before (done) ->
			@server = new Server()
			done()

		it 'Should reject when supplied with null', (done) ->
			@server._getEntryById(null).then (value) ->
				throw value
			, (err) ->
				(err == null).should.be.false
				done()

		it 'Should reject when supplied with a number', (done) ->
			@server._getEntryById(40).then (value) ->
				throw value
			, (err) ->
				(err == null).should.be.false
				done()

		it 'Should reject when supplied with non existant ID as string', (done) ->
			@server._getEntryById("aaaaaaaaaaaaaaaaaaaaaaaa").then (value) ->
				throw value
			, (err) ->
				(err == null).should.be.false
				done()

		it 'Should reject when supplied with non existant ID as an objectId', (done) ->
			@server._getEntryById(mongojs.ObjectId "aaaaaaaaaaaaaaaaaaaaaaaa").then (value) ->
				throw value
			, (err) ->
				(err == null).should.be.false
				done()

		it 'Should return correctly formatted object when give correct ID as a string', (done) ->
			@server._getEntryById("5395ba367b5c62a002b8dc51")
			.then (doc) =>
				doc.should.have.type 'object'
				@checkEntryFormatPreJSON doc
				done()
			, (err) ->
				throw err

		it 'Should return object when give correct ID as an objectID', (done) ->
			@server._getEntryById(mongojs.ObjectId "5395ba367b5c62a002b8dc4b")
			.then (doc) =>
				@checkEntryFormatPreJSON doc
				doc.should.have.type 'object'
				done()
			, (err) ->
				throw err