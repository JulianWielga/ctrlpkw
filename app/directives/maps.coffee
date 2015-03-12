'use strict'

angular.module 'directives.googleMaps', [
	'cordova.plugin.googleMaps'
]

.directive 'map', [
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
	'initMaps', '$injector', '$scope', '$q', '$cordovaGeolocation', 'locationMonitor'
	class MapController

		constructor: (@initMaps, @injector, @scope, @q, @geolocation, @locationMonitor) ->
			angular.extend @scope,
				centerFn: @center

			@scope.$on '$destroy', @destructor

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
			pos = @Map.latLng @locationMonitor?.lastPosition?.coords?.latitude or 0, @locationMonitor?.lastPosition?.coords?.longitude or 0
			@Map.getMap element,
				center: pos
				zoom: 5

		onInit: =>
			@scope.$watch 'markers', @markersChanged, yes

		center: (onlyLocation) =>
			clearTimeout @centerTimeout

			center = (position) =>
				@centerTimeout = setTimeout =>
					pos = @Map.latLng position.coords.latitude, position.coords.longitude
					if @markers and not onlyLocation
						points = (@Map.getMarkerPositon marker for marker in @markers)
						@q.all points
						.then (points) =>
							points.push pos
							bounds = @Map.latLngBounds points
							@Map.fitBounds @map, bounds
					else
						@Map.panTo @map, pos
				, 250

			if @locationMonitor.lastPosition
				center @locationMonitor.lastPosition
			else
				@geolocation.getCurrentPosition()
				.then (position) =>
					center position

		markersChanged: (markers) => if markers?.length
			@cleanMarkers()
			promises = (@createMarker marker for marker in markers)
			@q.all promises
			.then (markers) =>
				@markers = markers
				@center()
				return @markers

		cleanMarkers: =>
			return unless @markers?.length
			if @map.clear?
				@map.clear()
				@map.off()
				return

			for marker, i in @markers
				@removeMarker marker
				delete @markers[i]

		removeMarker: (marker) =>
			@Map.deleteMarker marker

		createMarker: (marker) =>
			@Map.createMarker @map,
				position: @Map.latLng marker.location.latitude, marker.location.longitude
				title: marker.address

		destructor: =>
			@cleanMarkers()
#			@map.remove?()
]

