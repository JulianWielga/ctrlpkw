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
	'angularMoment'
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
	'$mdThemingProvider', '$mdColorPalette'
	($mdThemingProvider, $mdColorPalette) ->
		$mdThemingProvider.definePalette 'pkw',
			'50': '#ffebee'
			'100': '#ffcdd2'
			'200': '#ef9a9a'
			'300': '#e57373'
			'400': '#ef5350'
			'500': '#f44336'
			'600': '#e53935'
			'700': '#d4213d' #d32f2f
			'800': '#c62828'
			'900': '#b71c1c'
			'A100': '#ff8a80'
			'A200': '#ff5252'
			'A400': '#ff1744'
			'A700': '#d50000'
			'contrastDefaultColor': 'light'
			'contrastDarkColors': '50 100 200 300 400 A100'
			'contrastStrongLightColors': '500 600 700 A200 A400 A700'

		$mdThemingProvider.theme 'default'
		.primaryPalette 'pkw',
			'default': '700'
		.accentPalette 'grey',
			'default': '800'
]

.run [
	'amMoment'
	(amMoment) ->
		amMoment.changeLocale('de')
]
