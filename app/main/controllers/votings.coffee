'use strict'

angular.module 'main.controllers.votings', [
	'RequestContext'
]

.controller 'VotingsController', [
	'$scope'
	'RenderContextFactory'
	'ApplicationData'
	'$page'

	class VotingsController
		constructor: (@scope, RenderContext, @data, $page) ->
			renderContext = new RenderContext @scope, 'votings'
			$page.title = 'Wybory'
			@data.getVotings()

]