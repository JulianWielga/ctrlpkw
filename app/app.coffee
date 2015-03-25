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
	'ngCordova.plugins.camera'

	# jade / html templates and templates
	'app.templates'
]

.config [
	'$routeProvider'
	'$locationProvider'

	($routeProvider, $locationProvider) ->
		$routeProvider

		.when '/votings', action: 'votings'
		.when '/voting', action: 'voting'
		.when '/voting/:date', action: 'voting'
		.when '/wards', action: 'wards'
		.when '/ward/:community/:no', action: 'ward'
		.otherwise redirectTo: '/voting'

]

.config [
	'$httpProvider'
	($httpProvider, config) ->
		$httpProvider.defaults.useXDomain = yes
#		$httpProvider.defaults.withCredentials = yes
]