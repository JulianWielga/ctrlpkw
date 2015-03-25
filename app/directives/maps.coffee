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
			centerMapFn: '='
			getMapCenterFn: '='
			onInit: '='
			onMarkerClick: '='
			masked: '='
			image: '='

		link: (scope, element, attrs, ctrl) ->
			ctrl.init element[0]

			scope.$watch 'masked', (masked) ->
				return unless ctrl.Map?.getImage?
				if masked
					ctrl.Map.getImage ctrl.map
					.then (imageData) ->
						scope.image =
							url: imageData
							height: element.parent()[0].clientHeight
							width: element.parent()[0].clientWidth
				else
					scope.image?.url = null

]

.controller 'mapController', [
	'initMaps', '$injector', '$scope', '$q', '$cordovaGeolocation', 'locationMonitor', '$document'
	class MapController

		constructor: (@initMaps, @injector, @scope, @q, @geolocation, @locationMonitor, @document) ->
			angular.extend @scope,
				centerMapFn: @centerOnLocation
				getMapCenterFn: @getView

			@scope.$on '$destroy', @destructor

		init: (element) =>
			@_injectPlugin()
			.then =>
				@map ?= @_createMap element
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
				zoom: 12

		onInit: =>
			@scope.$watch 'markers', @markersChanged, yes
#			@document.one 'location_changed', @centerOnLocation
			setTimeout =>
				@centerOnLocation()
				console.log 'onInit'
				@scope.onInit?()
			, 250

		_doCenterOnLocation: => _.debounce (position) =>
			pos = @Map.latLng position.coords.latitude, position.coords.longitude
			@Map.panTo @map, pos
		, 250

		centerOnLocation: =>
			console.log 'centerOnLocation'
			@doCenterOnLocation ?= @_doCenterOnLocation()
			@resizeHandler()
			if @locationMonitor.lastPosition
				@doCenterOnLocation @locationMonitor.lastPosition
			else
				@geolocation.getCurrentPosition().then (position) =>
					@doCenterOnLocation position

		createCircleForPoints: (center, points) =>
			console.log 'createCircleForPoints'
			c =
				lat: center.coords.latitude
				lng: center.coords.longitude
			radius = center.coords.radius
			for point in points
				pt =
					lat: point.lat?() or point.lat
					lng: point.lng?() or point.lng
				distance = @Map.distance(c, pt)
				radius = Math.max distance, radius
			@Map.createCircle @map,
				center: @Map.latLng c.lat, c.lng
				radius: radius
				fillColor: 'rgba(0,0,0,0)'
				strokeWeight: 2

		_doCenterOnMarkers: => (position) =>
			console.log 'centerOnMarkers'
			pos = @Map.latLng position.coords.latitude, position.coords.longitude
			@Map.deleteCircle @viewCircle
			points = (@Map.getMarkerPositon marker for marker in @markers)
			@q.all points
			.then (points) =>
				@createCircleForPoints position, points
				.then (circle) =>
					points.push pos
					bounds = @Map.latLngBounds points
					@viewCircle = circle
					@Map.fitBounds @map, bounds

		centerOnMarkers: (position) =>
			@doCenterOnMarkers ?= @_doCenterOnMarkers()
			return unless @markers
			if position
				@doCenterOnMarkers position
			else
				@getView().then @doCenterOnMarkers

		markersChanged: (markers) =>
			@resizeHandler()
			@doMarkersChanged markers

		doMarkersChanged: (markers) =>
			return unless markers?
			@document.off 'location_changed', @centerOnLocation
			@cleanMarkers()
			return unless markers.points?.length
			promises = (@createMarker marker for marker in markers.points)
			@q.all promises
			.then (_markers) =>
				@markers = _markers
				@centerOnMarkers markers.center
				return @markers

		getView: => @Map.getView @map

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
				m = @Map.createMarker @map,
					position: @Map.latLng marker.location.latitude, marker.location.longitude
			else
				m = @Map.createMarker @map,
					position: @Map.latLng marker.location.latitude, marker.location.longitude
					icon:
						url: "img/marker#{count}.png"
						size:
							width: 44/2
							height: 80/2
			m.then (el) =>
				@Map.onMarkerClick el, => @onMarkerClick marker
			return m

		onMarkerClick: (marker) =>
			@scope.onMarkerClick marker

		resizeHandler: =>
			@Map?.resize @map

		destructor: =>
			@cleanMarkers()
]

