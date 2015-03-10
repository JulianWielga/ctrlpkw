'use strict'

angular.module 'main.resources.votings', []

.factory 'VotingsResources', [
	'$resource'
	($resource) ->
		apiUrl = 'http://ctrlpkw.pl:80/api'

		$resource "#{apiUrl}/votings/:date/:action",
			{}
		,
			getWards:
				method: 'GET'
				params:
					action: 'wards'
					date: '@date'
				isArray: yes
]