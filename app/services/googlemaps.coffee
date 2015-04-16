# install   :     cordova plugin add plugin.google.maps
# link      :     https://github.com/wf9a5m75/phonegap-googlemaps-plugin


'use strict'

class Maps
	EARTH_RADIUS: 6370986

	toRad: (deg) -> deg * Math.PI / 180

	distance: (pt1, pt2) =>
		lat1 = @toRad pt1.lat
		lng1 = @toRad pt1.lng
		lat2 = @toRad pt2.lat
		lng2 = @toRad pt2.lng

		dlon = lng2 - lng1
		dlat = lat2 - lat1

		a = Math.pow((Math.sin(dlat/2)),2) + Math.cos(lat1) * Math.cos(lat2) * Math.pow(Math.sin(dlon/2),2)
		c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))

		return @EARTH_RADIUS * c;



angular.module 'cordova.plugin.googleMaps', [
	'cordova.Ready'
	'config.vars'
]

.factory "initMaps", [
	'$q', '$injector', 'crdReady', 'varsConfig'
	($q, $injector, crdReady, varsConfig) ->
		deferred = $q.defer()

		checkNative = crdReady ->
			console.debug 'checkNative'
			return checkJavascript() unless plugin?.google?.maps?.Map
			plugin.google.maps.Map.isAvailable (isAvailable, message) ->
				return checkJavascript() unless isAvailable
				nativeMaps()

		checkJavascript = ->
			console.debug 'checkJavascript'
			return javascriptMaps() if google?.maps?.Map
			callbackName = 'mapsInit'
			window[callbackName] = ->
				javascriptMaps()
				clearTimeout timeout
				delete window[callbackName]
			timeout = setTimeout ->
				noMaps()
				delete window[callbackName]
			, 10000
			url = "#{varsConfig.googleMaps}/js?key=#{varsConfig.mapsApiKey}"
			script = document.createElement 'script'
			script.type = 'text/javascript'
			script.src = "#{url}&callback=#{callbackName}"
			document.body.appendChild script

		nativeMaps = ->
			console.debug 'nativeMaps'
			deferred.resolve $injector.get 'googleMapsNative'

		javascriptMaps = ->
			console.debug 'javascriptMaps'
			deferred.resolve $injector.get 'googleMapsJS'

		noMaps = ->
			console.debug 'noMaps'
			deferred.reject 'No maps'

		checkNative()

		return deferred.promise
]

.service "googleMapsNative", [
	'$q', '$rootScope'
	class GoogleMapsNative extends Maps
		constructor: (@q, @rootScope) ->

		getMap: (canvas, params) ->
			parent = angular
			.element(canvas)
			.css(display: 'none')
			.parent()[0]
			map = plugin.google.maps.Map.getMap parent,
				backgroundColor: params.backgroundColor
				controls:
					zoom: no
					compass: yes
					myLocation: yes
					myLocationButton: no
				camera:
					latLng: params.center
					tilt: params.tilt
					zoom: params.zoom
					bearing: params.bearing

			map.on plugin.google.maps.event.CAMERA_CHANGE, @_onMapCameraChanged(map)

			@rootScope.$on 'EXIT_APP', -> map.remove()

			return map

		_onMapCameraChanged: (map) => =>
			@getView map
			.then (position) =>
				@rootScope.$broadcast 'MAP_VIEW_CHANGE', position

		fitBounds: (map, bounds) ->
			map.setPadding 60
			map.animateCamera
				target: bounds
				duration: 1000
			setTimeout -> map.setPadding 0

		panTo: (map, position, zoom) -> map.getCameraPosition (camera) ->
			map.animateCamera
				target: position
				zoom: zoom or camera.zoom
				duration: 1000

		moveTo: (map, position, zoom) -> map.getCameraPosition (camera) ->
			map.moveCamera
				target: position
				zoom: zoom or camera.zoom

		latLng: (latitude, longitude) ->
			new plugin.google.maps.LatLng latitude, longitude

		latLngBounds: (points) ->
			new plugin.google.maps.LatLngBounds points

		createMarker: (map, options) =>
			deferred = @q.defer()
			if options.icon
				options.icon.url = "www/#{options.icon.url}"
			map.addMarker options, (marker) ->
				deferred.resolve marker
			deferred.promise

		getMarkerPositon: (marker) =>
			deferred = @q.defer()
			marker?.getPosition (value) ->
				deferred.resolve value
			deferred.promise

		deleteMarker: (marker) ->
			marker?.remove()

		createCircle: (map, options) =>
			deferred = @q.defer()
			params = angular.extend
				fillColor: 'rgba(1,97,248,.2)'
				radius: 10
				strokeWidth: options.strokeWeight or 0
				strokeColor: 'rgba(0,0,0,.2)'
			, options
			map.addCircle params, (circle) ->
				deferred.resolve circle
			deferred.promise

		deleteCircle: (circle) =>
			@deleteMarker circle

		resize: (map) =>
			map?.refreshLayout()

		getImage: (map) =>
			deferred = @q.defer()
			map?.toDataURL (imageData) =>
				deferred.resolve imageData
			deferred.promise

		getView: (map) =>
			deferred = @q.defer()
			map.getVisibleRegion (bounds) =>
				map.getCameraPosition (camera) =>
					center = bounds.getCenter()
					deferred.resolve
						bounds: bounds
						zoom: camera.zoom
						coords:
							latitude: center.lat
							longitude: center.lng
							radius: @radius bounds
			deferred.promise

		radius: (bounds) =>
			center = bounds.getCenter()
			ne = bounds.northeast
			pt1 =
				lat: center.lat
				lng: center.lng
			pt2 =
				lat: ne.lat
				lng: ne.lng
			return @distance pt1, pt2

		onMarkerClick: (marker, callback) =>
			marker.addEventListener plugin.google.maps.event.MARKER_CLICK, callback


]

.service "googleMapsJS", [
	'$q', '$cordovaGeolocation', '$document', 'locationMonitor', '$rootScope'
	class GoogleMapsJS extends Maps
		constructor: (@q, @geolocation, @document, @locationMonitor, @rootScope) ->

		getMap: (canvas, params) =>
			@document.off 'location_changed', @_locationChangeHandler

			angular.extend params,
				disableDefaultUI: yes

			map = new google.maps.Map canvas, params
			@_locationChangeHandler = @_createLocationChangeHandler map
			@_locationChangeHandler()

			@document.on 'location_changed', @_locationChangeHandler
			google.maps.event.addListener map, 'center_changed', @_onMapCameraChanged(map)
			return map

		_onMapCameraChanged: (map) => =>
			@getView map
			.then (position) =>
				@rootScope.$broadcast 'MAP_VIEW_CHANGE', position

		_createLocationChangeHandler: (map) =>
			locationMarker = null
			locationAccuracyCircle = null

			=> if @locationMonitor.lastPosition?
				coords = @locationMonitor.lastPosition.coords
				position = @latLng coords.latitude, coords.longitude
				accuracy = coords.accuracy
				unless locationMarker
					locationMarker = {}
					scaledSize = 64 * .375
					anchor = scaledSize / 2
					@createMarker map,
						position: position
						icon:
							url: 'img/location.png'
							scaledSize: new google.maps.Size scaledSize, scaledSize
							anchor: new google.maps.Point anchor, anchor
					.then (marker) ->
						locationMarker = marker

					locationAccuracyCircle = {}
					@createCircle map,
						center: position
						radius: accuracy
					.then (circle) ->
						locationAccuracyCircle = circle
				else
#					locationMarker.setPosition position
#					locationAccuracyCircle.setCenter position
#					locationAccuracyCircle.setRadius accuracy
					@_animateMarkerMove locationMarker, position
					@_animateCircleResize locationAccuracyCircle, accuracy
					@_animateMarkerMove locationAccuracyCircle, position

		_moveMarker: (marker, latlngs, index, wait) =>
			marker.setPosition?(latlngs[index])
			marker.setCenter?(latlngs[index])
			if index != latlngs.length - 1
				setTimeout (=>
					@_moveMarker marker, latlngs, index + 1, wait
				), wait

		_resizeCircle: (circle, radius, index, wait) =>
			circle.setRadius?(radius[index])
			if index != radius.length - 1
				setTimeout (=>
					@_resizeCircle circle, radius, index + 1, wait
				), wait

		_animateMarkerMove: (marker, position) => if marker
			frames = []
			percent = 0
			p = marker.getPosition?() or marker.getCenter?()
			return unless p
			clat = p.lat()
			clng = p.lng()
			while percent < 1
				curLat = clat + percent * (position.lat() - clat)
				curLng = clng + percent * (position.lng() - clng)
				frames.push @latLng(curLat, curLng)
				percent += 0.01
			@_moveMarker marker, frames, 0, 20

		_animateCircleResize: (marker, radius) =>
			frames = []
			percent = 0
			cr = marker?.getRadius?()
			return unless cr
			while percent < 1
				curR = cr + percent * (radius - cr)
				frames.push curR
				percent += 0.01
			@_resizeCircle marker, frames, 0, 20

		fitBounds: (map, bounds) => map.fitBounds bounds

		panTo: (map, position, zoom) =>
			map.panTo position
			map.setZoom zoom if zoom?

		moveTo: (map, position, zoom) =>
			map.setCenter position
			map.setZoom zoom if zoom?

		latLng: (latitude, longitude) ->
			new google.maps.LatLng latitude, longitude

		latLngBounds: (points) ->
			bounds = new google.maps.LatLngBounds points[0], points[0]
			for point in points[1..]
				bounds.extend point if point
			return bounds

		createMarker: (map, options) =>
			deferred = @q.defer()

			if options.icon?.size?.width
				options.icon.scaledSize = new google.maps.Size options.icon.size.width, options.icon.size.height
				delete options.icon.size

			marker = new google.maps.Marker angular.extend
				map: map
			, options
			deferred.resolve marker
			deferred.promise

		getMarkerPositon: (marker) =>
			deferred = @q.defer()
			if marker
				deferred.resolve marker.getPosition()
			else
				deferred.reject()
			deferred.promise

		deleteMarker: (marker) ->
			marker?.setMap null

		createCircle: (map, options) =>
			deferred = @q.defer()
			fillColor = new Color(options.fillColor) if options.fillColor?
			strokeColor = new Color(options.strokeColor) if options.strokeColor?
			params = angular.extend
				map: map
				fillColor: fillColor?.toRGBString() or 'rgb(1, 97, 248)'
				fillOpacity: fillColor?.alpha or 0.2
				radius: 10
				strokeWeight: 0
				strokeColor: strokeColor?.toRGBString() or 'rgb(0, 0, 0)'
				strokeOpacity: strokeColor?.alpha or 0.2
			, options
			deferred.resolve new google.maps.Circle params
			deferred.promise

		deleteCircle: (circle) =>
			@deleteMarker circle

		resize: (map) =>
			google.maps.event.trigger map, 'resize'

		getView: (map) =>
			deferred = @q.defer()

			bounds = map.getBounds()
			center = bounds.getCenter()

			deferred.resolve
				bounds: bounds
				zoom: map.getZoom()
				coords:
					latitude: center.lat()
					longitude: center.lng()
					radius: @radius bounds
			deferred.promise

		radius: (bounds) =>
			center = bounds.getCenter()
			ne = bounds.getNorthEast()
			pt1 =
				lat: center.lat()
				lng: center.lng()
			pt2 =
				lat: ne.lat()
				lng: ne.lng()
			return @distance pt1, pt2

		onMarkerClick: (marker, callback) =>
			google.maps.event.addListener marker, 'click', callback
]