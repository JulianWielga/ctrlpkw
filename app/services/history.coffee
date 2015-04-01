'use strict'

angular.module 'touk.jwl.history', []

.service '$history', [
	'$q'
	'$rootScope'
	'$location'

	class History
		$states: []
		$replace: no
		constructor: (@$q, $scope, @$location) ->
			$scope.$on '$locationChangeSuccess', => @add()
			angular.extend $scope, history: @

			$scope.$watch (=> @$states), =>
				console.debug 'history', @$states
			, yes

		add: (path = @$location.path()) =>
			if @$replace
				@$states.pop()
				@$replace = no
			if path.length > 0 and _.last(@$states) isnt path
				@$states.push path
#			@clean() if _.first(@$states) is _.last(@$states)

		replace: => @$replace = yes

		last: => _.last @$states

		hasPrevious: => @$states.length > 1

		clean: =>
			@$replace = no
			@$states = _.takeRight @$states

		back: (steps = 1) =>
			@$replace = no
			if @$states.length > 1
				@$states = _.dropRight @$states, steps
				@$location.replace()
				@$location.path _.last @$states
]

.run [
	'$history', '$timeout'
	($history, $timeout) ->
		document.addEventListener 'backbutton', (event) ->
			event.preventDefault()
			$timeout =>
				$history.back() or navigator?.app?.exitApp?()
		, false
]