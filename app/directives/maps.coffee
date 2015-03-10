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
			centerFn: '='

		link: (scope, element, attrs, ctrl) ->
			ctrl.init element[0]
]

.controller 'mapController', [
	'initMaps', '$injector', '$scope', '$q', '$cordovaGeolocation'
	class MapController

		lastPosition: null

		constructor: (@initMaps, @injector, @scope, @q, @geolocation) ->
			@scope.centerFn = @center

		init: (element) =>
			@_injectPlugin()
			.then =>
				@map = @_createMap element
				return @map
			.then => @onInit()

		_injectPlugin: =>
			@q.when @initMaps
			.then (maps) => @Map = maps
			.catch (error) => alert error

		_createMap: (element) =>
			@Map.getMap element,
				center: @Map.latLng 0,0
				zoom: 3

		onInit: =>
			@scope.$watch 'markers', @markersChanged, yes
			@geolocation.watchPosition().then null, null, (position) =>
				@lastPosition = @Map.latLng position.coords.latitude, position.coords.longitude
			@center()

		center: (withMarkers) =>
			center = =>
				if withMarkers and @markers
					points = (@Map.getMarkerPositon marker for marker in @markers)
					@q.all points
					.then (points) =>
						points.push @lastPosition
						bounds = @Map.latLngBounds points
						@Map.fitBounds @map, bounds
				else
					@Map.panTo @map, @lastPosition

			if @lastPosition
				center()
			else
				@geolocation.getCurrentPosition()
				.then (position) =>
					pos = @Map.latLng position.coords.latitude, position.coords.longitude
					@map.setCenter pos
					@lastPosition = pos
				.then center

		markersChanged: (markers, oldMarkers) => if markers
			@cleanMarkers()
			return unless markers.length
			promises = (@createMarker marker for marker in markers)
			@q.all promises
			.then (markers) =>
				@markers = markers
				@center yes
				return @markers

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

