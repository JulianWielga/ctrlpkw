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
			getMapCenterFn: '='
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
				centerFn: @centerOnLocation
				getMapCenterFn: @getView

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
				zoom: 12

		onInit: =>
			@scope.$watch 'markers', @markersChanged, yes
			@document.one 'location_changed', @centerOnLocation

		_doCenterOnLocation: => _.debounce (position) =>
			pos = @Map.latLng position.coords.latitude, position.coords.longitude
			@Map.panTo @map, pos
		, 250

		centerOnLocation: =>
			@doCenterOnLocation ?= @_doCenterOnLocation()
			if @locationMonitor.lastPosition
				@doCenterOnLocation @locationMonitor.lastPosition
			else
				@geolocation.getCurrentPosition().then (position) =>
					@doCenterOnLocation position

		_doCenterOnMarkers: => _.debounce =>
			return unless @markers
			@getView().then (position) =>
				pos = @Map.latLng position.coords.latitude, position.coords.longitude
				@Map.deleteCircle @viewCircle
				points = (@Map.getMarkerPositon marker for marker in @markers)
				@q.all points
				.then (points) =>
					points.push pos
					bounds = @Map.latLngBounds points
					ne = bounds.getNorthEast?() or bounds.northeast
					sw = bounds.getSouthWest?() or bounds.southwest
					c =
						lat: position.coords.latitude
						lng: position.coords.longitude

					lat1 = ne.lat?() or ne.lat
					lat2 = sw.lat?() or sw.lat
					lng1 = ne.lng?() or ne.lng
					lng2 = sw.lng?() or sw.lng

					pt1 =
						lat: lat1
						lng: lng1
					pt2 =
						lat: lat2
						lng: lng1
					pt3 =
						lat: lat2
						lng: lng2
					pt4 =
						lat: lat1
						lng: lng2
					radius = Math.max @Map.distance(c, pt1),@Map.distance(c, pt2),@Map.distance(c, pt3),@Map.distance(c, pt4)
					radius = Math.max radius, (Math.min 5000, (position.coords.radius / 2 or 0))
					@Map.createCircle @map,
						center: pos
						radius: radius + 5
						fillColor: 'transparent'
						strokeWeight: 2
					.then (circle) =>
						@viewCircle = circle
						@Map.fitBounds @map, bounds
		, 250

		centerOnMarkers: =>
			@doCenterOnMarkers ?= @_doCenterOnMarkers()
			@doCenterOnMarkers()

		markersChanged: (markers) => if markers?
			@document.off 'location_changed', @centerOnLocation
			@cleanMarkers()
			return unless markers.length
			promises = (@createMarker marker for marker in markers)
			@q.all promises
			.then (markers) =>
				@markers = markers
				@centerOnMarkers()
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

