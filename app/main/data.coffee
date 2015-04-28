'use strict'

MAX_RADIUS = 5000
DEBOUNCE_TIMEOUT = 250

angular.module 'main.data', []

.service 'ApplicationData', [
	'$rootScope'
	'VotingsResources', 'ProtocolsResources'
	'mapData'

	class ApplicationData
		votings: []
		selectedVoting: null

		ballots: []

		wardsCount: 3
		wards: []
		selectedWards: []
		markers: []

		constructor: ($rootScope, @votingsResources, @protocolsResources, @mapSavedData) ->
			@getWards = _.debounce @_getWards, DEBOUNCE_TIMEOUT

			$rootScope.$watch (=> @selectedVoting), @_onVotingChanged

		_onVotingChanged: =>
			@wards = []
			@selectedWards = []
			@markers = []
			@clearMapData()

			@getBallots() if @selectedVoting

		clearMapData: =>
			@mapSavedData.bounds = null
			@mapSavedData.coords = null
			@mapSavedData.zoom = null

		_getWards: (position) =>
			@wardsLoading = yes

			@selectedWards = []
			position.coords.radius = Math.min(MAX_RADIUS, position.coords.radius / 2 or 0)
			request = @votingsResources.getWards
				date: @selectedVoting
				minCount: @wardsCount
				latitude: position.coords.latitude
				longitude: position.coords.longitude
				radius: position.coords.radius

			request.$promise.then (@wards) =>
				return unless @wards.length

				points = _.chain(@wards)
				.groupBy (ward) ->
					[ward.location.latitude, ward.location.longitude]
				.map (group) ->
					location: group[0].location
					wards: group
				.value()

				@markers =
					points: points
					center: position

			.finally =>
				@wardsLoading = no

			return request.$promise

		getVotings: =>
			if !@votings?.length
				@votings = @votingsResources.getVotings()
				@votings.$promise
				.then =>
					@selectedVoting ?= @votings[0].date
			return @votings.$promise

		getBallots: =>
			@ballots = @votingsResources.getBallots
				date: @selectedVoting

		saveProtocol: (protocol) =>
			@protocolsResources.save angular.extend
				votingDate: @selectedVoting
			, protocol

		currentVoting: =>
			if @selectedVoting?
				_.find(@votings, date: @selectedVoting)
]
