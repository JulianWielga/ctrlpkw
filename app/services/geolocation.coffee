# install   :     cordova plugin add org.apache.cordova.geolocation
# link      :     https://github.com/apache/cordova-plugin-geolocation/blob/master/doc/index.md

angular.module "ngCordova.plugins.geolocation", [
	'cordova.Ready'
]

.factory "$cordovaGeolocation", [
	"$q", 'crdReady'
	($q, cordovaReady) ->
		defaults =
			timeout: 20000
			maximumAge:	30 * 60 * 1000
#			enableHighAccuracy: yes

		getCurrentPosition: (options = {}) ->
			q = $q.defer()
			do cordovaReady ->
				navigator.geolocation.getCurrentPosition (result) ->
					q.resolve result
				, (err) ->
					q.reject err
				, _.defaults(options, defaults)
			q.promise

		watchPosition: (options = {}) ->
			q = $q.defer()
			do cordovaReady ->
				watchID = navigator.geolocation.watchPosition (result) ->
					q.notify result
				, (err) ->
					q.reject err
				, _.defaults(options, defaults)

				q.promise.cancel = ->
					navigator.geolocation.clearWatch watchID

				q.promise.clearWatch = (id) ->
					navigator.geolocation.clearWatch id or watchID

				q.promise.watchID = watchID
			q.promise

		clearWatch: (watchID) ->
			do cordovaReady ->
				navigator.geolocation.clearWatch watchID
]

.service "locationMonitor", [
	'$q', '$rootScope', '$cordovaGeolocation', '$document'
	class LocationMonitor
		promise: null
		lastPosition: null

		constructor: (@q, @rootScope, @geolocation, @document) ->
			@document
			.on 'resume', @start
			.on 'pause', @stop
			@start()

		start: =>
			@stop()
			@promise = @geolocation.watchPosition()
			@promise.then null, null, (@lastPosition) =>
				@rootScope.$broadcast 'LOCATION_CHANGED', @lastPosition
				@document.triggerHandler 'location_changed'

		stop: =>
			@promise?.cancel?()
			@promise = null
]
