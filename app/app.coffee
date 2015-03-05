'use strict'

angular.module 'app', [
	# angular dependencies
	'ngAnimate'
	'ngResource'
	'ngSanitize'
	'ngRoute'

	# angular external dependencies
	'RequestContext'
	'angularLoad'
	'touk.jwl.ngFnQueue'

	# app modules
	'app.main'

	# jade / html templates and templates
	'app.templates'
]

#.config [
#	'$routeProvider'
#	'$locationProvider'
#
#	($routeProvider, $locationProvider) ->
#		$routeProvider
#
#		.when '/a', action: 'a'
#		.when '/b', action: 'b'
#		.otherwise redirectTo: '/a'
#
#]

.config [
	'$httpProvider'
	($httpProvider, config) ->
		$httpProvider.defaults.useXDomain = yes
		$httpProvider.defaults.withCredentials = yes
]
