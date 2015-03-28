'use strict'

angular.module 'main.controllers.wards', [
	'RequestContext'
]

.controller 'WardsController', [
	'$scope'
	'RenderContextFactory'
	'ApplicationData'
	'$cordovaGeolocation'
	'locationMonitor'
	'$location'
	'$history'
	'$page'

	class WardsController
		constructor: (@scope, RenderContext, @data, @cordovaGeolocation, @locationMonitor, @location, @history, $page) ->
			$page.title = 'Komisje wyborcze'
			renderContext = new RenderContext @scope, 'wards'

			if @data.selectedWards.length is 1
				ward = @data.selectedWards[0]
				@history.replace()
				@location.replace()
				@location.path "/wards/#{ward.communityCode}/#{ward.no}"

]