'use strict'

angular.module 'main.controllers.errors', [
	'main.services.errors'
]

.controller 'ErrorsController', [
	'$scope'
	'$page'
	'$errors'

	class ErrorsController

		constructor: ($scope, $page, $errors) ->
			$scope.$on '$destroy', -> $errors.clear()

]