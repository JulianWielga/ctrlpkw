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

	class WardsController
		constructor: (@scope, RenderContext, @data, @cordovaGeolocation, @locationMonitor, @location) ->
			renderContext = new RenderContext @scope, 'wards'

]