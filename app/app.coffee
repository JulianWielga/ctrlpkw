'use strict'

angular.module 'app', [
	# angular dependencies
	'ngAnimate'
	'ngResource'
	'ngSanitize'
	'ngRoute'
#	'ngTouch'

	# angular external (bower) dependencies
	'RequestContext'
	'angularLoad'
	'angularMoment'
	'angularSpinner'
	'touk.promisedLink'
	'touk.jwl.ngFnQueue'
	'touk.jwl.history'
	'touk.jwl.page'
	'ng.deviceDetector'
	'uuid4'
	'LocalStorageModule'

	# app modules
	'main.module'
	'directives.googleMaps'
	'validators.responseValidators'

	#'app.services'
	'cordova.Ready'
	'ngCordova.plugins.geolocation'
	'ngCordova.plugins.camera'
	'config.vars'

	# jade / html templates and templates
	'app.templates'
]

.config [
	'$routeProvider'
	'$locationProvider'

	($routeProvider, $locationProvider) ->
		$routeProvider

		.when '/votings', action: 'votings'

		.when '/wardsmap', action: 'wardsmap'
		.when '/wardsmap/:date', action: 'wardsmap'

		.when '/wards', action: 'wards'
		.when '/wards/:date', action: 'wards'

		.when '/wards/:community/:no', action: 'ward'
		.when '/wards/:community/:no/ballots', action: 'ward'

		.when '/wards/:community/:no/ballots/:ballot', action: 'ward.ballot'
		.when '/wards/:community/:no/ballots/:ballot/photos', action: 'ward.ballot.photos'
		.when '/wards/:community/:no/ballots/:ballot/share', action: 'ward.ballot.share'


		.otherwise redirectTo: '/wards'

		$locationProvider.html5Mode no
]

.config [
	'$httpProvider'
	($httpProvider) ->
		$httpConfigDefaults =
			timeout: 10000

		$httpProvider.defaults.useXDomain = yes
#		$httpProvider.defaults.withCredentials = yes
		$httpProvider.interceptors.push [
			'$q', '$location', 'varsConfig', 'localStorageService'
			($q, $location, varsConfig, localStorageService) ->
				request: (config = {}) ->
					_.defaults(config, $httpConfigDefaults)
					angular.extend config.headers,
						'ctrl-pkw-client-version': varsConfig.version
						'Ctrl-PKW-Client-Id': localStorageService.get('clientId')

					if transforms = config.transformResponse
						transforms = [transforms] unless angular.isArray(transforms)
					else
						defaults = $httpProvider.defaults.transformResponse
						transforms = [defaults] unless angular.isArray(defaults)

					transforms.unshift (data, headersGetter, status) ->
						hUuid = headersGetter()['Ctrl-PKW-Client-Id']
						sUuid = localStorageService.get('clientId')
						if hUuid? and hUuid isnt sUuid
							localStorageService.set 'clientId', hUuid

						#TODO: jakiś inny warunek, jakaś inna akcja...
						if status is 403
							title = 'Nowa wersja aplikacji'
							text = 'Masz nieaktualną wersję aplikacji. Pobierz najnowszą wersję ze sklepu, ta nie będzie działać.'
							navigator.notification.alert text, ->
								window.open headersGetter().location, '_system'
							, title, 'Uaktualnij'
						return data

					config.transformResponse = transforms
					return config

		]
]

.config [
	'usSpinnerConfigProvider'
	(usSpinnerConfigProvider) ->
		usSpinnerConfigProvider.setDefaults
			color: 'black'
			hwaccel: true
			lines: 12
			length: 12
			width: 5
			radius: 15
			corners: 1
]

.run [
	'amMoment'
	(amMoment) ->
		amMoment.changeLocale 'pl'
		FastClick.attach document.body
]

.run [
	'localStorageService', 'uuid4'
	(localStorageService, uuid4) ->
		uuid = localStorageService.get 'clientId'
		unless uuid
			uuid = uuid4.generate()
			localStorageService.set 'clientId', uuid
]
