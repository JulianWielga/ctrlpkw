'use strict'

angular.module 'directives.googleMaps', [
	'cordova.plugin.googleMaps'
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

.controller 'mapController', [
	'initMaps', '$injector', '$scope', '$q', '$cordovaGeolocation'
	class MapController
		markers: []

		constructor: (@initMaps, @injector, @scope, @q, @geolocation) ->

		init: (element) =>
			@_injectPlugin()
			.then => @map = @_createMap element
			.then => @onInit()

		_injectPlugin: =>
			@q.when @initMaps
			.then (maps) => @Map = maps
			.catch (error) => alert error

		_createMap: (element) =>
			@Map.getMap element,
				center: @Map.latLng 52.2099674,20.9608946
				zoom: 15

		onInit: =>
			@scope.$watch 'markers', @markersChanged, yes
			@geolocation.getCurrentPosition().then (position) =>
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
			@Map.createMarker @map,
				position: @Map.latLng marker.location.latitude, marker.location.longitude
				title: marker.address
]

