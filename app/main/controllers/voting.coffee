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

	class VotingController
		constructor: (@scope, RenderContext, @data, @cordovaGeolocation, @locationMonitor, @location, @timeout) ->
			renderContext = new RenderContext @scope, 'voting', 'date'
			if votingDate = renderContext.getParam('date')
				@data.selectedVoting = votingDate
			else if @data.selectedVoting?
				@location.path "/voting/#{@data.selectedVoting}"
				@location.replace()

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