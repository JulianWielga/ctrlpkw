'use strict'

angular.module 'main.errors', []

.service 'ApplicationErrors', [

	'$timeout'
	'crdReady'

	class ApplicationErrors

		noNetworkConnection: false
		noLocationService: false
		upgradeRequired: false

		constructor: ($timeout, cordovaReady) ->
			@timeout = $timeout
			do cordovaReady =>
				@_checkNetworkStatus()
				document.addEventListener "offline", @_checkNetworkStatus, false
				document.addEventListener "online", @_checkNetworkStatus, false



		_checkNetworkStatus: =>
			@timeout =>
				navigator.connection.getInfo (info) =>
					navigator.connection.type = info
				, (e) =>
					console.warn(e)
				@noNetworkConnection = (navigator.connection.type == Connection.UNKNOWN || navigator.connection.type == Connection.NONE)
]
