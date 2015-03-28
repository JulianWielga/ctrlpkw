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
			if votingDate = renderContext.getParam('date')
				@data.selectedVoting = votingDate
			else
				@data.votings.$promise.then =>
					@history.replace()
					@location.replace()
					@location.path "/voting/#{@data.selectedVoting}"

		init: =>
			@getWards yes

		getWards: (init) =>
			if @getMapCenter? and not init
				@getMapCenter().then @data.getWards
			else if @locationMonitor?.lastPosition
				@data.getWards @locationMonitor.lastPosition
			else
				@cordovaGeolocation.getCurrentPosition().then @data.getWards

		onMarkerClick: (marker) =>
			@data.selectedWards = marker.wards
			@scope.$apply => @location.path '/wards'
]