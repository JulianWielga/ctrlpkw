'use strict'

angular.module 'main.data', [
]

.service 'ApplicationData', [
	'$rootScope'
	'VotingsResources'
	class ApplicationData
		markers: []
		votings: []
		ballots: []
		count: 3
		selectedVoting: null
		selectedWards: []

		constructor: ($rootScope, @resources) ->
			@getWards = _.debounce @_getWards, 250

			@votings = @resources.getVotings()
			@votings.$promise.then =>
				@selectedVoting ?= @votings[0].date

			$rootScope.$watch =>
				@selectedVoting
			, => if @selectedVoting
				@getBallots()

		_getWards: (position) =>
			position.coords.radius = Math.min(5000, position.coords.radius / 2 or 0)
			@resources.getWards
				date: @selectedVoting
				latitude: position.coords.latitude
				longitude: position.coords.longitude
				radius: position.coords.radius
				minCount: @count
			.$promise.then (values) =>
				if values.length
					points = _.chain(values)
					.groupBy (marker) ->
						[marker.location.latitude, marker.location.longitude]
					.map (group) ->
						location: group[0].location
						wards: group
					.value()
					@markers =
						points: points
						center: position

		getBallots: =>
			@ballots = @resources.getBallots
				date: @selectedVoting

		saveProtocol: (protocol) =>
			@resources.saveProtocol angular.extend
				date: @selectedVoting
			, protocol

]
