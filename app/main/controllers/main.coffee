'use strict'

angular.module 'main.controllers.main', [
	'RequestContext'
]

.controller 'MainCtrl', [
	'$scope'
	'$route'
	'$routeParams'
	'requestContext'
	'VotingsResources'
	'$cordovaGeolocation'
	'$location'
	'locationMonitor'

	($scope, $route, $routeParams, requestContext, VotingsResources, $cordovaGeolocation, $location, locationMonitor) ->
		# Get the render context local to this controller (and relevant params).
		renderContext = requestContext.getRenderContext()

		# I check to see if the given route is a valid route; or, is the route being
		# re-directed to the default route (due to failure to match pattern).
		isRouteRedirect = (route) -> not route.current.action

		# The subview indicates which view is going to be rendered on the page.
		$scope.subview = renderContext.getNextSection()

		# I handle changes to the request context.
		$scope.$on "requestContextChanged", ->
			return unless renderContext.isChangeRelevant()
			$scope.subview = renderContext.getNextSection()

		# Listen for route changes so that we can trigger request-context change events.
		$scope.$on "$routeChangeSuccess", (event) ->
			# If this is a redirect directive, then there's no taction to be taken.
			return if isRouteRedirect($route)

			# Update the current request action change.
			requestContext.setContext $route.current.action, $routeParams

			# Announce the change in render conditions.
			$scope.$broadcast "requestContextChanged", requestContext




		@getWards = =>
			$cordovaGeolocation.getCurrentPosition().then (position) =>
				@markers = VotingsResources.getWards
					date: '2010-06-20'
					latitude: position.coords.latitude
					longitude: position.coords.longitude
					count: @count
#				@markers.$promise
#				.then (values) =>
#					$location.path 'map'

		@center = =>
			@centerMap yes

]