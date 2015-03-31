'use strict'

angular.module 'main.controllers.voting', [
	'RequestContext'
]

.controller 'VotingController', [
	'$scope'
	'RenderContextFactory'
	'ApplicationData'
	'$cordovaGeolocation'
	'locationMonitor'
	'$location'
	'$timeout'
	'$history'
	'$page'

	class VotingController
		constructor: (@scope, RenderContext, @data, @cordovaGeolocation, @locationMonitor, @location, @timeout, @history, $page) ->
			$page.title = 'Komisje wyborcze'
			$page.subtitle = 'Wybierz na mapie komisję wyborczą w danej lokalizacji'
			renderContext = new RenderContext @scope, 'voting', 'date'

			@scope.$on "requestContextChanged", =>
				return unless renderContext.isChangeRelevant()
				@contextChanged renderContext

			@contextChanged renderContext

		contextChanged: (renderContext) =>
			@history.clean()
			@data.selectedWards = []
			if votingDate = renderContext.getParam('date')
				@data.selectedVoting = votingDate
			else
				@data.votings.$promise.then =>
					@history.replace()
					@location.replace()
					@location.path "/voting/#{@data.selectedVoting}"

		init: =>
			@updateWards() unless @data.wards.length

		updateWards: =>
			@data.clearMapData()
			@getMapCenter?().then @data.getWards

		onMarkerClick: (marker) =>
			@data.selectedWards = marker.wards
			@scope.$apply => @location.path '/wards'
]