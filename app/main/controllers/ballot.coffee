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
	'$history'

	class BallotController
		constructor: (@scope, RenderContext, @data, @camera, @cloudinary, @location, @history) ->
			renderContext = new RenderContext @scope, 'ward.ballot', ['community', 'no', 'ballot']

			@scope.$watch =>
				@ballotNo
			, =>
				@ballot = _.find @data.ballots, no: @ballotNo

			@scope.$on "requestContextChanged", =>
				return unless renderContext.isChangeRelevant()
				@init(renderContext)

			@images = []
			@result = votesCountPerOption: []
			@init(renderContext)

		init: (renderContext) =>
			@communityCode = renderContext.getParam 'community'
			@wardNo = renderContext.getParam 'no'
			@ballotNo = renderContext.getParamAsInt 'ballot'

			@history.replace() #if @scope.subview

		sum: =>
			_.reduce @result.votesCountPerOption, (sum, value) -> (sum or 0) + (value or 0)

		sendResult: =>
			@loading = yes
			@request = @data.saveProtocol
				ballotNo: @ballot.no
				communityCode: @communityCode
				wardNo: @wardNo
				ballotResult: @result
			@request.$promise.then (response) =>
				@uploadParams = response
			.finally =>
				@loading = no
			return @request.$promise

		takePhoto: (choose) =>
			@camera.getPicture
				destinationType: Camera.DestinationType.DATA_URL
				sourceType: if choose then Camera.PictureSourceType.PHOTOLIBRARY else Camera.PictureSourceType.CAMERA
				correctOrientation: yes
				saveToPhotoAlbum: yes
				quality: 49
			.then (uri) =>
				@loading = yes
				image = {}
				image.res = @cloudinary.save
					api_key: @uploadParams.apiKey
					timestamp: @uploadParams.timestamp
					signature: @uploadParams.signature
					public_id: @uploadParams.publicId
					file: "data:image/jpeg;base64,#{uri}"

				image.res.$promise.finally => @loading = no
				image.src = "data:image/jpeg;base64,#{uri}"
				@images.push image
]