'use strict'

angular.module 'main.controllers.wardsmap', [
	'RequestContext'
]

.controller 'WardsmapController', [
	'$scope'
	'RenderContextFactory'
	'ApplicationData'
	'$cordovaGeolocation'
	'locationMonitor'
	'$location'
	'$timeout'
	'$history'
	'$page'

	class WardsmapController
		constructor: (@scope, RenderContext, @data, @cordovaGeolocation, @locationMonitor, @location, @timeout, @history, @page) ->
			renderContext = new RenderContext @scope, 'wardsmap', 'date'

			@scope.$on "requestContextChanged", =>
				return unless renderContext.isChangeRelevant()
				@contextChanged renderContext

			@contextChanged renderContext

		contextChanged: (renderContext) =>
#			@history.clean()
			@data.selectedWards = []
			if votingDate = renderContext.getParam('date')
				@data.selectedVoting = votingDate
			else
				@data.votings.$promise.then =>
					@history.replace()
					@location.replace()
					@location.path "/wardsmap/#{@data.selectedVoting}"

		init: =>
			@updateWards() unless @data.wards.length
			@page.title = 'Lokale wyborcze'

		updateWards: =>
			@data.clearMapData()
			@getMapCenter?().then (position) =>
				@data.getWards?(position)

		onMarkerClick: (marker) =>
			@data.selectedWards = marker.wards
			@scope.$apply => @location.path '/wards'
]