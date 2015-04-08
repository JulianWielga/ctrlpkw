'use strict'

angular.module 'app', [
	# angular dependencies
	'ngAnimate'
	'ngResource'
	'ngSanitize'
	'ngRoute'
#	'ngTouch'

	# angular external (bower) dependencies
	'RequestContext'
	'angularLoad'
	'angularMoment'
	'angularSpinner'
	'touk.promisedLink'
	'touk.jwl.ngFnQueue'
	'touk.jwl.history'
	'touk.jwl.page'
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
		.when '/wards/:date', action: 'wards'

		.when '/wards/:community/:no', action: 'ward'
		.when '/wards/:community/:no/ballots', action: 'ward'

		.when '/wards/:community/:no/ballots/:ballot', action: 'ward.ballot'
		.when '/wards/:community/:no/ballots/:ballot/photos', action: 'ward.ballot.photos'
		.when '/wards/:community/:no/ballots/:ballot/share', action: 'ward.ballot.share'


		.otherwise redirectTo: '/wards'

		$locationProvider.html5Mode no
]

.config [
	'$httpProvider'
	($httpProvider, config) ->
		$httpProvider.defaults.useXDomain = yes
#		$httpProvider.defaults.withCredentials = yes
]

.config [
	'usSpinnerConfigProvider'
	(usSpinnerConfigProvider) ->
		usSpinnerConfigProvider.setDefaults
			color: 'black'
			hwaccel: true
			lines: 12
			length: 12
			width: 5
			radius: 15
			corners: 1
]

.run [
	'amMoment'
	(amMoment) ->
		amMoment.changeLocale 'pl'
		FastClick.attach document.body
]
