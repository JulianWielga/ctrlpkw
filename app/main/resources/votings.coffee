'use strict'

#apiUrl = 'http://ctrlpkw.pl:80/api'

angular.module 'main.resources.votings', [
	'config.api'
]

.factory 'VotingsResources', [
	'$resource', 'apiConfig'
	($resource, apiConfig) ->

		$resource "#{apiConfig.base}/votings/:date/:action",
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
	'$resource', 'apiConfig'
	($resource, apiConfig) ->

		$resource "#{apiConfig.base}/protocols/:id", {}
]