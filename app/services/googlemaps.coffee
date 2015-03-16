# install   :     cordova plugin add plugin.google.maps
# link      :     https://github.com/wf9a5m75/phonegap-googlemaps-plugin


'use strict'

angular.module 'cordova.plugin.googleMaps', []

.factory "initMaps", [
	'$q', '$injector', 'crdReady'
	($q, $injector, crdReady) ->
		deferred = $q.defer()

		checkNative = crdReady ->
			return checkJavascript() unless plugin?.google?.maps?.Map
			plugin.google.maps.Map.isAvailable (isAvailable, message) ->
				return checkJavascript() unless isAvailable
				nativeMaps()

		checkJavascript = ->
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
			mapsApiKey = 'AIzaSyDvoIJEBVWnFvqMnSLPvu4Ce7cD8tJmNjc'
			url = "https://maps.googleapis.com/maps/api/js?key=#{mapsApiKey}"
			script = document.createElement 'script'
			script.type = 'text/javascript'
			script.src = "#{url}&callback=#{callbackName}"
			document.body.appendChild script

		nativeMaps = ->
			deferred.resolve $injector.get 'googleMapsNative'

		javascriptMaps = ->
			deferred.resolve $injector.get 'googleMapsJS'

		noMaps = ->
			deferred.reject 'No maps'

		checkNative()

		return deferred.promise
]

.service "googleMapsNative", [
	'$q'
	class GoogleMapsNative
		constructor: (@q) ->

		getMap: (canvas, params) ->
			map = plugin.google.maps.Map.getMap canvas,
				backgroundColor: params.backgroundColor
				controls:
					zoom: no
					compass: yes
					myLocationButton: yes
				camera:
					latLng: params.center
					tilt: params.tilt
					zoom: params.zoom
					bearing: params.bearing
			return map

		fitBounds: (map, bounds) ->
			map.setPadding 30
			map.animateCamera
				target: bounds
				duration: 1000
			setTimeout -> map.setPadding 0

		panTo: (map, position) -> map.getCameraPosition (camera) ->
			map.animateCamera
				target: position
				zoom: camera.zoom
				duration: 1000

		latLng: (latitude, longitude) ->
			new plugin.google.maps.LatLng latitude, longitude

		latLngBounds: (points) ->
			new plugin.google.maps.LatLngBounds points

		createMarker: (map, options) =>
			deferred = @q.defer()
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
				fillColor: '#0000FF'
				fillOpacity: 0.2
				radius: 10
				strokeWeight: 0
			, options
			map.addCircle params, (circle) ->
				deferred.resolve circle
			deferred.promise

		resize: (map) =>
			map?.refreshLayout()

]

.service "googleMapsJS", [
	'$q', '$cordovaGeolocation', '$document', 'locationMonitor'
	class GoogleMapsJS
		constructor: (@q, @geolocation, @document, @locationMonitor) ->

		getMap: (canvas, params) =>
			@document.off 'location_changed', @_locationChangeHandler

			angular.extend params,
				disableDefaultUI: yes

			map = new google.maps.Map canvas, params
			@_locationChangeHandler = @_createLocationChangeHandler map
			@_locationChangeHandler()

			@document.on 'location_changed', @_locationChangeHandler
			return map

		_createLocationChangeHandler: (map) =>
			locationMarker = null
			locationAccuracyCircle = null

			=>
				coords = @locationMonitor.lastPosition.coords
				position = @latLng coords.latitude, coords.longitude
				accuracy = coords.accuracy
				unless locationMarker
					locationMarker = {}
					size = 64
					scaledSize = size * .375
					anchor = scaledSize / 2
					@createMarker map,
						position: position
						icon:
							url: 'img/location.png'
							size: new google.maps.Size size, size
							scaledSize: new google.maps.Size scaledSize, scaledSize
							origin: new google.maps.Point 0, 0
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

		panTo: (map, position) => map.panTo position

		latLng: (latitude, longitude) ->
			new google.maps.LatLng latitude, longitude

		latLngBounds: (points) ->
			bounds = new google.maps.LatLngBounds points[0], points[0]
			for point in points[1..]
				bounds.extend point if point
			return bounds

		createMarker: (map, options) =>
			deferred = @q.defer()
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
			params = angular.extend
				map: map
				fillColor: '#0161f8'
				fillOpacity: 0.2
				radius: 10
				strokeWeight: 0
			, options
			deferred.resolve new google.maps.Circle params
			deferred.promise

		resize: (map) =>
			google.maps.event.trigger map, 'resize'
]
