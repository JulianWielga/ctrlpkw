'use strict'

angular.module 'directives.cordovaPlatform', []

.directive 'cordovaPlatform', [
	'$rootScope'
	($rootScope) ->
		restrict: 'A'
		link: (scope, element) ->
			platform = cordova?.platformId or 'not-cordova'
			element.addClass "platform-#{platform}"
			$rootScope.platformId = platform
]