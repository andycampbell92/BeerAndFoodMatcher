exports = exports ? this
class BeerAndFoodAPI
	constructor: ->
		@apiAddress = 'http://localhost:8080'

	getHighLevelData: ->
		getDataURL = '/getData'
		deferred = Q.defer()
		$.ajax {
		  dataType: "json"
		  ,url: @apiAddress+getDataURL
		  ,success: (data) ->
		  	try
		  		parsed = JSON.parse data
		  		deferred.resolve parsed
		  	catch error
		  		deferred.reject error
		  ,error: (error) ->
		  	deferred.reject error
		}
		return deferred.promise

	getNode: (nodeID) ->
		getDataURL = '/getData/'+nodeID
		deferred = Q.defer()
		$.ajax {
		  dataType: "json"
		  ,url: @apiAddress+getDataURL
		  ,success: (data) ->
		  	try
		  		parsed = JSON.parse data
		  		deferred.resolve parsed
		  	catch error
		  		deferred.reject error
		  ,error: (error) ->
		  	deferred.reject error
		}
		return deferred.promise

exports.BeerAndFoodAPI = BeerAndFoodAPI