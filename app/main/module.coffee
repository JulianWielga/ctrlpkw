'use strict'

### Controllers ###

angular.module 'app.main', [
	'main.controllers.main'
]

.factory 'cordovaReady', [
	'$q', '$document', 'fnQueue'
	($q, $document, fnQueue) ->
		deferred = $q.defer()
		$document.one 'deviceready', -> deferred.resolve()
		return fnQueue(deferred.promise)
]

.factory "geolocation", [
	'cordovaReady'
	(cordovaReady) ->
		getCurrentPosition: cordovaReady -> navigator.geolocation.getCurrentPosition arguments...
		watchPosition: cordovaReady -> navigator.geolocation.watchPosition arguments...
		clearWatch: cordovaReady -> navigator.geolocation.clearWatch arguments...
]

.factory "nativeMaps", [
	'$q'
	($q) ->
		getMap: (canvas, params) ->
			plugin.google.maps.Map.getMap canvas,
				backgroundColor: params.backgroundColor
				controls:
					zoom: no
					myLocationButton: yes
				camera:
					latLng: params.center
					tilt: params.tilt
					zoom: params.zoom
					bearing: params.bearing

		latLng: (latitude, longitude) ->
			new plugin.google.maps.LatLng latitude, longitude

		createMarker: (map, position, title) ->
			deferred = $q.defer()
			map.addMarker
				position: position
				title: title
			, (marker) ->
				deferred.resolve marker
			deferred.promise

		deleteMarker: (marker) ->
			marker.remove()

		createCircle: (map, options) ->
			deferred = $q.defer()
			params = angular.extend
				fillColor: '#0000FF'
				fillOpacity: 0.2
				radius: 10
				strokeWeight: 0
			, options
			map.addCircle params, (circle) ->
				deferred.resolve circle
			deferred.promise

]

.factory "jsMaps", [
	'$q'
	($q) ->
		getMap: (canvas, params) ->
			new google.maps.Map canvas, angular.extend params,
				disableDefaultUI: yes

		latLng: (latitude, longitude) ->
			new google.maps.LatLng latitude, longitude

		createMarker: (map, position, title) ->
			deferred = $q.defer()
			marker = new google.maps.Marker
				position: position
				map: map
				title: title
			deferred.resolve marker
			deferred.promise

		deleteMarker: (marker) ->
			marker.setMap null

		createCircle: (map, options) ->
			deferred = $q.defer()
			params = angular.extend
				fillColor: 'blue'
				fillOpacity: 0.2
				radius: 10
				strokeWeight: 0
				map: map
			, options
			deferred.resolve new google.maps.Circle params
			deferred.promise
]

.factory "mapsTest", [
	'$q', 'cordovaReady'
	($q, cordovaReady) ->
		deferred = $q.defer()

		do cordovaReady ->
			nativeMaps = ->
				plugin.google.maps.Map.isAvailable (isAvailable, message) ->
					if isAvailable
						deferred.resolve 'nativeMaps'
					else
						noMaps message

			javascriptMaps = ->
				deferred.resolve 'jsMaps'

			noMaps = (message) ->
				deferred.reject message or 'no maps'

			if plugin?.google?.maps?.Map
				nativeMaps()
			else if google?.maps?.Map
				javascriptMaps()
			else
				noMaps()

		return deferred.promise
]

.controller 'mapController', [
	'mapsTest', '$injector', '$scope', '$q', 'geolocation'
	class MapController
		markers: []

		constructor: (@mapsTest, @injector, @scope, @q, @geolocation) ->

		init: (element) =>
			@_injectPlugin()
			.then => @map = @_createMap element
			.then => @locationWatchStart()
			.then => @onInit()

		locationWatchStart: =>
#			@geolocation.watchPosition (position) =>
#				pos = @Map.latLng position.coords.latitude, position.coords.longitude
#				rad = position.coords.accuracy
#
#				unless @currentLoc
#					@currentLoc = @Map.createMarker @map, pos, 'test'
#					.then (currentLoc) =>
#						@currentLoc = currentLoc
#
#					@currentLocRadius = @Map.createCircle @map,
#						center: pos
#						radius: rad
#					.then (circle) =>
#						@currentLocRadius = circle
#
#				else
#					@currentLoc.setPosition pos
#					@currentLocRadius.setCenter pos
#					@currentLocRadius.setRadius rad

		_injectPlugin: =>
			@mapsTest
			.then (dep) => @Map = @injector.get dep
			.catch (error) => alert error

		_createMap: (element) =>
			@Map.getMap element,
				center: @Map.latLng 52.2099674,20.9608946
				zoom: 15

		onInit: =>
			@scope.$watch 'markers', @markersChanged, yes
			@geolocation.getCurrentPosition (position) =>
				@map.setCenter @Map.latLng position.coords.latitude, position.coords.longitude


		markersChanged: (markers) => if markers
			@cleanMarkers()
			promises = (@createMarker marker for marker in markers)
			@q.all promises
			.then (markers) => @markers = markers

		cleanMarkers: =>
			return unless @markers?.length
			for marker, i in @markers
				@removeMarker marker
				delete @markers[i]

		removeMarker: (marker) =>
			@Map.deleteMarker marker

		createMarker: (marker) =>
			position = @Map.latLng marker.location.latitude, marker.location.longitude
			@Map.createMarker @map, position, marker.address
]

.directive 'mapCanvas', [
	'$q'
	($q) ->
		restrict: 'AE'
		controller: 'mapController'
		controllerAs: 'ctrl'
		scope:
			markers: '='
		link: (scope, element, attrs, ctrl) ->
			ctrl.init element[0]

]

