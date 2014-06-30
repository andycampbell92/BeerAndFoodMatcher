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

	describe 'Should get first level of beer styles and links', ->
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

	describe 'All links should link back to this object', ->
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

					for el in responseData
						for link in el.links
							if link.links.indexOf(el._id) == -1
								console.log "Problem with links"
								console.log el
								console.log link
								throw "Link did not link back to this object"

					done()


	describe 'Should get a fully expanded node given a ID', ->
		address = '/getData'
		it 'Should have a correctly structured json object including link objects', (done) ->
			args = '/5395ba367b5c62a002b8dc52'
			request @url
				.get address + args
				.expect('Content-Type', /json/)
				.expect(200)
				.end (err, res) =>
					node = JSON.parse res.body
					# This will throw if request fails or expects are not fufilled
					if err
						throw err

					@checkEntryFormatPostJSON node
					for linkedNode in node.links
						@checkEntryFormatPostJSON linkedNode

					done()

		it 'Should have a correctly structured json object when given an ID without links', (done) ->
			args = '/5395ba367b5c62a002b8dc3c'
			request @url
				.get address + args
				.expect('Content-Type', /json/)
				.expect(200)
				.end (err, res) =>
					node = JSON.parse res.body
					# This will throw if request fails or expects are not fufilled
					if err
						throw err

					@checkEntryFormatPostJSON node
					done()

		it 'Should fail if given a non existant id', (done) ->
			args = '/9395ba357b5c62a002b8dc0b'
			request @url
				.get address + args
				.expect('Content-Type', /json/)
				.expect(200)
				.end (err, res) =>
					(err == null).should.be.false
					if err
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

		it 'Should reject when supplied with an incorrectly formatted ID', (done) ->
			@server._getEntryById("invalid").then (value) ->
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
				doc.should.have.type 'object'
				@checkEntryFormatPreJSON doc
				done()
			, (err) ->
				throw err

	describe 'Get multiple database entries (beer, food, beer style) from array of ID\'s', ->
		before (done) ->
			@server = new Server()
			done()

		it 'Should fail if given something other than an array', (done) ->
			@server._getListOfEntriesById("entry")
			.then (value) =>
				throw value
			, (err) =>
				(err == null).should.be.false
				done();

		it 'Should fail if one (or more) of the ID\'s is invalid', (done) ->
			@server._getListOfEntriesById(["5395ba357b5c62a002b8dc0b", "invalid"])
			.then (value) =>
				throw value
			, (err) =>
				(err == null).should.be.false
				done()

		it 'Should fail if one (or more) of the ID\'s does not exist', (done) ->
			@server._getListOfEntriesById(["5395ba357b5c62a002b8dc1b", "5395ba357b5c62a002g8dc0a"])
			.then (value) =>
				throw value
			, (err) =>
				(err == null).should.be.false
				done()

		it 'Should fail if given an empty list', (done) ->
			@server._getListOfEntriesById([])
			.then (value) =>
				throw value
			, (err) =>
				(err == null).should.be.false
				done()

		it 'Should return an array of valid objects given a list of valid ID\'s as strings', (done) ->
			@server._getListOfEntriesById(["5395ba357b5c62a002b8dc0b", "5395ba357b5c62a002b8dc0a", "5395ba357b5c62a002b8dc09"])
			.then (docs) =>
				for doc in docs
					doc.should.have.type 'object'
					@checkEntryFormatPreJSON doc
				done()
			, (err) =>
				(err == null).should.be.true
				throw err
		
		it 'Should return an array of valid objects given a list of valid ID\'s as objectId\'s', (done) ->
			objectIdList = [mongojs.ObjectId "5395ba357b5c62a002b8dc0b", mongojs.ObjectId "5395ba357b5c62a002b8dc0a", mongojs.ObjectId "5395ba357b5c62a002b8dc09"]
			@server._getListOfEntriesById(objectIdList)
			.then (docs) =>
				for doc in docs
					doc.should.have.type 'object'
					@checkEntryFormatPreJSON doc
				done()
			, (err) =>
				(err == null).should.be.true
				throw err

	describe 'Expands the links from ID\'s to the objects that they represent', ->
		before (done) ->
			@server = new Server()
			done()

		it 'Should return a set of embedded documents when given a document with links', (done) ->
			doc = {	
				_id: 'name not resolved',
				name: 'testName',
				superNode: true,
				type: 'beer',
				links: ["5395ba357b5c62a002b8dc0b", "5395ba357b5c62a002b8dc0a", "5395ba357b5c62a002b8dc09"]
			}

			@server._resolveLinks(doc)
			.then (doc) =>
				for embDoc in doc.links
					embDoc.should.have.type 'object'
					@checkEntryFormatPreJSON embDoc
				done()
			, (err) =>
				(err == null).should.be.true
				throw err