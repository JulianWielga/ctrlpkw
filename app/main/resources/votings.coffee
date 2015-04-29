'use strict'

#apiUrl = 'http://ctrlpkw.pl:80/api'

angular.module 'main.resources.votings', [
	'config.vars'
]

.factory 'VotingsResources', [
	'$resource', 'varsConfig'
	($resource, varsConfig) ->

		$resource "#{varsConfig.api}/votings/:date/:action",
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
	'$resource', 'varsConfig'
	($resource, varsConfig) ->

		$resource "#{varsConfig.api}/protocols/:id", {}
]

.factory 'PictureUploadAuthorizationResource', [
	'$resource', 'varsConfig'
	($resource, varsConfig) ->

		$resource "#{varsConfig.api}/protocols/:protocolId/image/:imageId"

]