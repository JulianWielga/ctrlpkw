'use strict'

apiUrl = 'http://ctrlpkw.pl:80/api'

angular.module 'main.resources.votings', []

.factory 'VotingsResources', [
	'$resource'
	($resource) ->

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

]

.factory 'ProtocolsResources', [
	'$resource'
	($resource) ->

		$resource "#{apiUrl}/protocols/:id", {}
]