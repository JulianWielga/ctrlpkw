'use strict'

angular.module 'touk.jwl.page', []

.service '$page', [
	'$rootScope'
	'$timeout'

	class Page
		title: ''
		constructor: ($scope, @$timeout) ->
			$scope.page = @
]

.run ['$page', ($page)->]