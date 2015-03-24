'use strict'

angular.module 'main.controllers.votings', [
	'RequestContext'
]

.controller 'VotingsController', [
	'$scope'
	'RenderContextFactory'
	'ApplicationData'
	'$cordovaGeolocation'
	'locationMonitor'

	class VotingsController
		constructor: (@scope, RenderContext, @data, @cordovaGeolocation, @locationMonitor) ->
			renderContext = new RenderContext @scope, 'votings'

]