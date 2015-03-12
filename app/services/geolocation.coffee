# install   :     cordova plugin add org.apache.cordova.geolocation
# link      :     https://github.com/apache/cordova-plugin-geolocation/blob/master/doc/index.md

angular.module "ngCordova.plugins.geolocation", []

.factory "$cordovaGeolocation", [
	"$q", 'crdReady'
	($q, cordovaReady) ->
		getCurrentPosition: (options) ->
			q = $q.defer()
			do cordovaReady ->
				navigator.geolocation.getCurrentPosition (result) ->
					q.resolve result
				, (err) ->
					q.reject err
				, options
			q.promise

		watchPosition: (options) ->
			q = $q.defer()
			do cordovaReady ->
				watchID = navigator.geolocation.watchPosition (result) ->
					q.notify result
				, (err) ->
					q.reject err
				, options

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
	'$q', '$cordovaGeolocation', '$document'
	class LocationMonitor
		promise: null
		lastPosition: null

		constructor: (@q, @geolocation, @document) ->
			@document
			.on 'resume', @start
			.on 'pause', @stop
			@start()

		start: =>
			@stop()
			@promise = @geolocation.watchPosition().then null, null, (position) =>
				@lastPosition = position
				@document.triggerHandler 'location_changed'

		stop: =>
			@promise?.cancel()
			@promise = null
]
