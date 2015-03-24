'use strict'

angular.module 'main.resources.votings', []

.factory 'VotingsResources', [
	'$resource'
	($resource) ->
		apiUrl = 'http://ctrlpkw.pl:80/api'

		$resource "#{apiUrl}/votings/:date/:action",
			date: '@date'
		,
			getVotings:
				method: 'GET'
				isArray: yes

			getWards:
				method: 'GET'
				params:
					action: 'wards'
				isArray: yes

			getBallots:
				method: 'GET'
				params:
					action: 'ballots'
				isArray: yes

			saveProtocol:
				method: 'POST'
				params:
					action: 'protocols'
				transformRequest: (data) ->
					angular.toJson _.omit(data, 'date')
				isArray: yes
]