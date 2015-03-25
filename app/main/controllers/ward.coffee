'use strict'

angular.module 'main.controllers.ward', [
	'RequestContext'
	'main.resources.cloudinary'
]

.controller 'WardController', [
	'$scope'
	'RenderContextFactory'
	'ApplicationData'
	'$cordovaCamera'
	'CloudinaryResources'
	'$location'


	class WardController
		constructor: (@scope, RenderContext, @data, @camera, @cloudinary, @location) ->
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
			@request.$promise.then (response) => @uploadParams = response

		takePhoto: (ballotParams) =>
			@camera.getPicture
				destinationType: Camera.DestinationType.DATA_URL
				correctOrientation: yes
				saveToPhotoAlbum: yes
				quality: 49
			.then (uri) =>
				@cloudinary.save
					api_key: ballotParams.apiKey
					timestamp: ballotParams.timestamp
					signature: ballotParams.signature
					public_id: ballotParams.publicId
					file: "data:image/jpeg;base64,#{uri}"

				@imageUri = uri
]