should = require('should');
request = require('supertest');  

# Test for our REST services
describe 'RestSevice', ->
	before (done) ->
		@url = "http://localhost:8080"
		done()

	describe 'First level of beer styles and links', ->
		address = '/getData'
		it 'Should have a correctly structured json object', (done) ->
			request @url
				.get address
				.expect('Content-Type', /json/)
				.expect(200)
				.end (err, res) ->
					# This will throw if request fails or expects are not fufilled
					if err
						throw err
					# We should have data
					Object.keys(res.body).length.should.not.equal 0
					for key in res.body
						# Our key should be a number
						key.should.be.type 'number'
						# Beer names should be strings
						res.body[key].name.should.be.type 'string'
						# Our super node or not identifyer should be boolean
						res.body[key].superNode.should.be.type 'boolean'
						# Our beer type should be string
						res.body[key].type.should.be.type 'string'
						# Our links to other nodes should be an array
						Array.isArray(res.body[key].links).should.equal true
						# Every item in the link array should be a number
						for link in res.body[key].links
							link.should.be.type 'number'