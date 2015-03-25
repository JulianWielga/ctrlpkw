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

	class VotingController
		constructor: (@scope, RenderContext, @data, @cordovaGeolocation, @locationMonitor, @location) ->
			renderContext = new RenderContext @scope, 'voting', 'date'
			if votingDate = renderContext.getParam('date')
				@data.selectedVoting = votingDate

		getWards: =>
			if @getMapCenter?
				@getMapCenter().then @data.getWards
			if @locationMonitor?.lastPosition
				@data.getWards @locationMonitor.lastPosition
			else
				@cordovaGeolocation.getCurrentPosition().then @data.getWards

		onMarkerClick: (marker) =>
			@data.selectedWards = marker.wards
			@scope.$apply => @location.path '/wards'
]