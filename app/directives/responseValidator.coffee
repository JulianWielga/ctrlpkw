'use strict'

angular.module 'validators.responseValidators', []

.service 'ResponseValidators', [
	'$q'
	class ResponseValidators

		constructor: (@q) ->

		responseError: (rejection) => @q.reject rejection
]

.config [
	'$httpProvider'
	($httpProvider) ->
		$httpProvider.interceptors.push 'ResponseValidators'
]

.directive 'validateResponse', ['$parse', ($parse) ->
	restrict: 'A'
	scope: yes
	controller: ['$scope','$parse', class ResponseValidator

		constructor: ($scope, $parse) ->
			@fields = []

		setInvalid: (field, error) =>
			if field.model
				field.model.$setTouched()
				field.model.$setValidity 'remote', no

			field.text = error

		clearMessage: (field) => field.text = null
		clearInvalid: (field) => field.model.$setValidity 'remote', yes

		addField: (field) =>
			@fields.push field

		parseResponse: (errors) => if errors
			for field in @fields
				@clearMessage field
				for error in errors
					errorPath = error.path.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")
					console.log error.path, errorPath, field.path
					if field.path.match new RegExp "(\\.|^)#{errorPath}$", 'gi'
						@setInvalid field, error.message
	]
	link: (scope, element, attrs, ctrl) ->
		watcher = null
		attrs.$observe 'validateResponse', ->
			watcher?()

			responseErrorsGetter = $parse(attrs.validateResponse)

			setResponseErrors = (value) ->
				responseErrorsGetter.assign scope, value

			responseErrors = ->
				responseErrorsGetter scope

			watcher = scope.$watch responseErrors, (errors) ->
				ctrl.parseResponse errors
				setResponseErrors null
			, yes
]

.directive 'responseValidator', ['$parse', ($parse) ->
	restrict: 'A'
	require: ['?ngModel','^?validationMessage']
	link: (scope, element, attrs, ctrls) ->
		ngModel = ctrls[0]
		vMessage = ctrls[1]

		console.log $parse(attrs.responseValidator)(scope)
		angular.extend vMessage,
			model: ngModel
			path: $parse(attrs.responseValidator)(scope)
]

.directive 'validationMessage', ['$timeout', ($timeout) ->
	restrict: 'A'
	scope: yes
	controller: class ValidationMessage
		text: null
		model: null
		path: null

	controllerAs: 'vm'
	require: ['validationMessage', '?^validateResponse']
	link: (scope, element, attrs, ctrls) ->
		vMessage = ctrls[0]
		rValidator = ctrls[1]
		return unless rValidator
		$timeout ->
			return unless vMessage.path

			if vMessage.model
				clear = (value) ->
					rValidator.clearInvalid vMessage
					value

				vMessage.model.$parsers.push clear
				vMessage.model.$formatters.push clear

			rValidator.addField vMessage
]
