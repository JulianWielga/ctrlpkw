'use strict'

angular.module 'main.controllers.wards', [
	'RequestContext'
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

	class WardsController
		constructor: (@scope, $page, RenderContext, @data, @cordovaGeolocation, @locationMonitor, @location, @history, @timeout) ->
			$page.title = 'Komisje wyborcze'
			$page.subtitle = 'Wybierz na mapie komisję wyborczą w danej lokalizacji'
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
				@data.votings.$promise.then =>
					@history.replace()
					@location.replace()
					@location.path "/wards/#{@data.selectedVoting}"

		init: => @timeout =>
			unless @data.selectedWards?.length
				if @data.wards.length
					@data.selectedWards = @data.wards
				else
					@scope.$watch (=> return @data.wards), (wards) =>
						return unless wards?
						@data.selectedWards = wards
						@locationPending = no

					@timeout =>
						@locationPending = yes
						@getWards()

			if @data.selectedWards.length is 1
				ward = @data.selectedWards[0]
				@history.replace()
				@location.replace()
				@location.path "/wards/#{ward.communityCode}/#{ward.no}"

		getWards: =>
			if @locationMonitor?.lastPosition
				@data.getWards @locationMonitor.lastPosition
			else
				@cordovaGeolocation.getCurrentPosition().then @data.getWards

]