'use strict'

angular.module 'touk.jwl.history', []

.service '$history', [
	'$q'
	'$rootScope'
	'$location'
	'$timeout'

	class History
		$states: []
		$replace: no
		constructor: (@$q, $scope, @$location, @$timeout) ->
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
			@clean() if _.first(@$states) is _.last(@$states)

		replace: => @$replace = yes

		last: => _.last @$states

		hasPrevious: => @$states.length > 1

		clean: =>
			@$replace = no
			@$states = _.takeRight @$states

		back: (steps = 1) => @$timeout =>
			@$replace = no
			if @$states.length > 1
				@$states = _.dropRight @$states, steps
			@$location.replace()
			@$location.path _.last @$states
]

.run [
	'$history'
	($history) ->
		document.addEventListener 'backbutton', (event) ->
			event.preventDefault()
			$history.back()
		, false
]