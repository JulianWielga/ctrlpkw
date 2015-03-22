'use strict'

angular.module 'main.resources.votings', []

.factory 'VotingsResources', [
	'$resource'
	($resource) ->
		apiUrl = 'http://ctrlpkw.pl:80/api'

		$resource "#{apiUrl}/votings/:date/:action",
			{}
		,
			getVotings:
				method: 'GET'
				isArray: yes

			getWards:
				method: 'GET'
				params:
					action: 'wards'
					date: '@date'
				isArray: yes
]