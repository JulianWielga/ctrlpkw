'use strict'

angular.module 'directives.googleMaps', [
	'cordova.plugin.googleMaps'
]

.directive 'map', [
	'$q', '$document'
	($q, $document) ->
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
	'initMaps', '$injector', '$scope', '$q', '$cordovaGeolocation', 'locationMonitor', '$document'
	class MapController

		constructor: (@initMaps, @injector, @scope, @q, @geolocation, @locationMonitor, @document) ->
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
			@document.one 'location_changed', @center

		_doCenter: => _.debounce (position, onlyLocation) =>
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

		center: (onlyLocation) =>
			@doCenter ?= @_doCenter()
			if @locationMonitor.lastPosition
				@doCenter @locationMonitor.lastPosition, onlyLocation
			else
				@geolocation.getCurrentPosition()
				.then (position) =>
					@doCenter position, onlyLocation

		markersChanged: (markers) => if markers?
			@document.off 'location_changed', @center
			@cleanMarkers()
			return unless markers.length
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
			count = marker.wards?.length or ''
			if marker.wards?.length < 2
				@Map.createMarker @map,
					position: @Map.latLng marker.location.latitude, marker.location.longitude
			else
				@Map.createMarker @map,
					position: @Map.latLng marker.location.latitude, marker.location.longitude
					icon:
						url: "img/marker#{count}.png"
						size:
							width: 44/2
							height: 80/2

		resizeHandler: =>
			@Map?.resize @map

		destructor: =>
			@cleanMarkers()
#			@map.remove?()
]

