'use strict'

angular.module 'main.controllers.ward', [
	'RequestContext'
	'main.resources.cloudinary'
	'main.controllers.ballot'
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

			@scope.$on "requestContextChanged", =>
				return unless renderContext.isChangeRelevant()
				@init(renderContext)

			@init renderContext

			if @data.ballots.length is 1
				@openBallot @data.ballots[0]

		openBallot: (ballot) =>
			@location.path "/ward/#{@communityCode}/#{@wardNo}/ballots/#{ballot.no}"

		init: (renderContext) =>
			@communityCode = renderContext.getParam 'community'
			@wardNo = renderContext.getParam 'no'

]