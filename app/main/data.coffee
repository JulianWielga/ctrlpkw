'use strict'

angular.module 'main.data', [
]

.service 'ApplicationData', [
	'VotingsResources'
	class ApplicationData
		markets: []
		votings: []
		selectedVoting: null
		selectedWards: []
		count: 3
		constructor: (@resources) ->
			@votings = @resources.getVotings()
			@getWards = _.debounce @_getWards, 250

		_getWards: (position, date) =>
			@markers = []
			@resources.getWards
				date: @selectedVoting
				latitude: position.coords.latitude
				longitude: position.coords.longitude
				radius: Math.min(5000, position.coords.radius / 2 or 0)
				minCount: @count
			.$promise.then (values) =>
				if values.length
					@markers = _.chain(values)
					.groupBy (marker) ->
						[marker.location.latitude, marker.location.longitude]
					.map (group) ->
						location: group[0].location
						wards: group
					.value()
]