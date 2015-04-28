'use strict'

angular.module 'main.controllers.wards', [
	'RequestContext'
	'main.services.errors'
]

.controller 'WardsController', [
	'$scope'
	'$page'
	'RenderContextFactory'
	'ApplicationData'
	'$cordovaGeolocation'
	'locationMonitor'
	'$location'
	'$history'
	'$timeout'
	'$errors'

	class WardsController
		constructor: (@scope, $page, RenderContext, @data, @cordovaGeolocation, @locationMonitor, @location, @history, @timeout, @errors) ->
			$page.title = 'Lokale wyborcze'
			renderContext = new RenderContext @scope, 'wards', 'date'

			@scope.$on "requestContextChanged", =>
				return unless renderContext.isChangeRelevant()
				@contextChanged renderContext

			@contextChanged renderContext

		contextChanged: (renderContext) =>
			if votingDate = renderContext.getParam('date')
				@data.selectedVoting = votingDate
				@init()
			else
				@data.getVotings()
				.then =>
					@history.replace()
					@location.replace()
					@location.path "/wards/#{@data.selectedVoting}"
				.catch =>
					@errors.noNetworkConnection = true

		init: => @timeout =>
			unless @data.selectedWards?.length
				if @data.wards.length
					@data.selectedWards = @data.wards
				else
					@scope.$watch (=> return @data.wards), (wards) =>
						return unless wards?
						@data.selectedWards = wards

					@timeout =>
						@getWards()
					, 250

			if @data.selectedWards.length is 1
				ward = @data.selectedWards[0]
				@history.replace()
				@location.replace()
				@location.path "/wards/#{ward.communityCode}/#{ward.no}"

		getWards: =>
			@data.getVotings()
			.then =>
				@locationPending = yes
				if @locationMonitor?.lastPosition
					@data.getWards @locationMonitor.lastPosition
					@locationPending = no
				else
					@cordovaGeolocation.getCurrentPosition(timeout: 60000)
					.then @data.getWards
					.catch =>
						@errors.noLocationService= true
					.finally => @locationPending = no
			.catch =>
				@errors.noNetworkConnection = true

]