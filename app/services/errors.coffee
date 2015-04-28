angular.module "main.services.errors", []

.service '$errors', [

	class Errors

		noServiceLocation: false
		noNetworkConnection: false

		constructor: () ->

		hasAny: =>
			_.some _.omit @, ['hasAny','clear']

		clear: =>
			_.forEach _.omit(@, ['hasAny','clear']), (value, key) =>
				@[key] = false
				return true

]



