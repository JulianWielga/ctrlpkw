'use strict'

angular.module 'main.controllers.ballot', [
	'RequestContext'
	'main.resources.cloudinary'
]

.controller 'BallotController', [
	'$scope'
	'RenderContextFactory'
	'ApplicationData'
	'$cordovaCamera'
	'CloudinaryResources'
	'$location'


	class BallotController

		constructor: (@scope, RenderContext, @data, @camera, @cloudinary, @location) ->
			renderContext = new RenderContext @scope, 'ward.ballot', ['community', 'no', 'ballot']

			@scope.$on "requestContextChanged", =>
				return unless renderContext.isChangeRelevant()
				@init(renderContext)

			@init(renderContext)

		init: (renderContext) =>
			@images = []
			@result = []
			@communityCode = renderContext.getParam 'community'
			@wardNo = renderContext.getParam 'no'
			@ballot = _.find @data.ballots, no: renderContext.getParamAsInt 'ballot'

		sum: =>
			_.reduce @result, (sum, value) -> sum + value

		sendResult: =>
			@request = @data.saveProtocol
				ballotNo: @ballot.no
				communityCode: @communityCode
				wardNo: @wardNo
				ballotResult:
					votersEntitledCount: 0
					ballotsGivenCount: 0
					votesCastCount: 0
					votesValidCount: 0
					votesCountPerOption: @result
			@request.$promise.then (response) =>
#				TODO: zamienic pozniej jak Tomek poprawi
#				@uploadParams = response
				@uploadParams = response[0]

		takePhoto: =>
			@camera.getPicture
				destinationType: Camera.DestinationType.DATA_URL
				correctOrientation: yes
				saveToPhotoAlbum: yes
				quality: 49
			.then (uri) =>
				@cloudinary.save
					api_key: @uploadParams.apiKey
					timestamp: @uploadParams.timestamp
					signature: @uploadParams.signature
					public_id: @uploadParams.publicId
					file: "data:image/jpeg;base64,#{uri}"
				.$promise.then =>
					@images.push "data:image/jpeg;base64,#{uri}"
]