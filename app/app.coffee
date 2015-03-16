'use strict'

angular.module 'app', [
	# angular dependencies
	'ngAnimate'
	'ngResource'
	'ngSanitize'
	'ngRoute'
	'ngTouch'
	'ngMaterial'

	# angular external (bower) dependencies
	'RequestContext'
	'angularLoad'
	'touk.jwl.ngFnQueue'
	'ng.deviceDetector'

	# app modules
	'main.module'
	'directives.googleMaps'

	#'app.services'
	'cordova.Ready'
	'ngCordova.plugins.geolocation'

	# jade / html templates and templates
	'app.templates'
]

.config [
	'$routeProvider'
	'$locationProvider'

	($routeProvider, $locationProvider) ->
		$routeProvider

		.when '/home', action: 'home'
		.when '/form', action: 'form'
		.when '/map', action: 'map'
		.otherwise redirectTo: '/home'

]

.config [
	'$httpProvider'
	($httpProvider, config) ->
		$httpProvider.defaults.useXDomain = yes
#		$httpProvider.defaults.withCredentials = yes
]
