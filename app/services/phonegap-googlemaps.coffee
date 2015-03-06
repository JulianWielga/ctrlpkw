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

.factory "googleMapsNative", [
	'$q'
	($q) ->
		version: 'googleMapsNative'
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

.factory "googleMapsJS", [
	'$q'
	($q) ->
		version: 'googleMapsJS'
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
