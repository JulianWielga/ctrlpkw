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

			if @data.selectedWards.length is 1
				ward = @data.selectedWards[0]
				@location.path "/ward/#{ward.communityCode}/#{ward.no}"

]