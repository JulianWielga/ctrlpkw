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
			console.debug 'WardsController: contextChanged'
			@data.getVotings()
			.then =>
				votingDate = renderContext.getParam('date')
				console.log _(@data.votings).pluck('date').includes(votingDate)
				if votingDate? and _(@data.votings).pluck('date').includes(votingDate)
					@data.selectedVoting = votingDate
					@init()
				else
					@history.replace()
					@location.replace()
					@location.path "/wards/#{@data.selectedVoting}"
			.catch =>
				@errors.noNetworkConnection = true

		init: => @timeout =>
			console.debug 'WardsController: init'
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
					@cordovaGeolocation.getCurrentPosition()
					.then @data.getWards
					.catch =>
						@errors.noLocationService= true
					.finally => @locationPending = no

]