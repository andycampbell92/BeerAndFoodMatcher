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
					responseData = JSON.parse res.body
					# This will throw if request fails or expects are not fufilled
					if err
						throw err
					# We should have data
					Object.keys(responseData).length.should.not.equal 0
					for key in Object.keys(responseData)
						# Our key should be a number
						key.should.be.type 'string'
						# Beer names should be strings
						responseData[key].should.have.property('name').with.type 'string'
						# Our super node or not identifyer should be boolean
						responseData[key].should.have.property('superNode').with.type 'boolean'
						# Our beer type should be string
						responseData[key].should.have.property('type').with.type 'string'
						# Our links to other nodes should be an array
						responseData[key].should.have.property 'links'
						Array.isArray(responseData[key].links).should.equal true
						# Every item in the link array should be a number
						for link in responseData[key].links
							link.should.be.type 'number'
					done()