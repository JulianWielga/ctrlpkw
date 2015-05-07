'use strict'

MAX_RADIUS = 5000
DEBOUNCE_TIMEOUT = 250

angular.module 'main.data', []

.service 'ApplicationData', [
	'$rootScope'
	'VotingsResources', 'ProtocolsResources'
	'mapData'
	'$errors'

	class ApplicationData
		votings: []
		selectedVoting: null

		ballots: []

		wards: []
		selectedWards: []
		markers: []

		constructor: ($rootScope, @votingsResources, @protocolsResources, @mapSavedData, @errors) ->
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
					center: angular.extend {}, position

			.catch =>
				@errors.noNetworkConnection = true

			.finally =>
				@wardsLoading = no

			return request.$promise

		getVotings: =>
			unless @votings?.length
				@votingsLoading = yes
				@votings = @votingsResources.getVotings()
				@votings.$promise
				.then =>
					@selectedVoting ?= @votings[0].date
					@getBallots()
					return @selectedVoting
				.catch =>
					@errors.noNetworkConnection = true
				.finally =>
					@votingsLoading = no
			return @votings.$promise

		getBallots: =>
			@ballots = @votingsResources.getBallots
				date: @selectedVoting

		saveProtocol: (protocol) =>
			@protocolsResources.save
				authorizePictureUpload: false
			, angular.extend
				votingDate: @selectedVoting
			, protocol

		authorizePictureUpload: (protocolId) =>

		currentVoting: =>
			if @selectedVoting?
				_.find(@votings, date: @selectedVoting)
]
