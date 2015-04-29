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
	'PictureUploadAuthorizationResource'
	'$location'
	'$history'

	class BallotController
		constructor: (@scope, RenderContext, @data, @camera, @cloudinary, @pictureUploadAuthorization, @location, @history) ->
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
			@protocol = @data.saveProtocol
				ballotNo: @ballot.no
				communityCode: @communityCode
				wardNo: @wardNo
				ballotResult: @result
			@protocol.$promise.then =>
				console.log "protocol saved"
			.catch (res) =>
				@fieldErrors = res.data
			.finally =>
				@loading = no
			return @protocol.$promise

		takePhoto: (choose) =>
			@camera.getPicture
				destinationType: Camera.DestinationType.DATA_URL
				sourceType: if choose then Camera.PictureSourceType.PHOTOLIBRARY else Camera.PictureSourceType.CAMERA
				correctOrientation: yes
				saveToPhotoAlbum: yes
				quality: 49

			.then (uri) =>
				@loading = yes
				pictureUploadToken = @pictureUploadAuthorization.save
					protocolId: @protocol.id
				, {}

				pictureUploadToken.$promise.then (pictureUploadToken) =>
					image = {}
					image.res = @cloudinary.save
						api_key: pictureUploadToken.apiKey
						timestamp: pictureUploadToken.timestamp
						signature: pictureUploadToken.signature
						public_id: pictureUploadToken.publicId
						file: "data:image/jpeg;base64,#{uri}"

					image.res.$promise.finally => @loading = no
					image.src = "data:image/jpeg;base64,#{uri}"
					@images.push image

		shareFb: =>
			console.log 'costam costam facebook', @data.currentVoting()

		shareTw: =>
			console.log 'costam costam twitter', @data.currentVoting()
]
