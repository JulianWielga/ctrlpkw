'use strict'

angular.module 'directives.cordovaPlatform', []

.directive 'cordovaPlatform', ->
	restrict: 'A'
	link: (scope, element) ->
		platform = cordova?.platformId or 'not-cordova'
		element.addClass "platform-#{platform}"
		scope.platformId = platform