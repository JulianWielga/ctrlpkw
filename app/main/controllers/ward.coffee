'use strict'

angular.module 'main.controllers.ward', [
	'RequestContext'
]

.controller 'WardController', [
	'$scope'
	'RenderContextFactory'
	'ApplicationData'
	'$cordovaCamera'
	'$location'

	class WardController
		constructor: (@scope, RenderContext, @data, @camera, @location) ->
			renderContext = new RenderContext @scope, 'ward', ['community', 'no']
			@communityCode = renderContext.getParam 'community'
			@wardNo = renderContext.getParam 'no'

		sum: (ballot) =>
			_.reduce @result?[ballot], (sum, value) -> sum + value

		sendResult: =>
			@request = @data.saveProtocol
				communityCode: @communityCode
				wardNo: @wardNo
				ballotResults: _.map @result, (results, ballot) ->
					ballotNo: ballot
					votersEntitledCount: 0
					ballotsGivenCount: 0
					votesCastCount: 0
					votesValidCount: 0
					votesCountPerOption: _.values results

		takePhoto: =>
			@camera.getPicture().then (uri) => @imageUri = uri
]