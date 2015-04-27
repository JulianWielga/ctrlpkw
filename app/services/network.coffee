# install   :      cordova plugin add org.apache.cordova.network-information
# link      :      https://github.com/apache/cordova-plugin-network-information/blob/master/doc/index.md
angular.module('ngCordova.plugins.network', [
	'cordova.Ready'
])

.factory '$cordovaNetwork', [
	'$q'
	'$rootScope'
	'$timeout'
	'crdReady'
	($q, $rootScope, $timeout, cordovaReady) ->

		offlineEvent = ->
			networkState = navigator.connection.type
			$timeout ->
				$rootScope.$broadcast '$cordovaNetwork:offline', networkState
				return
			return

		onlineEvent = ->
			networkState = navigator.connection.type
			$timeout ->
				$rootScope.$broadcast '$cordovaNetwork:online', networkState
				return
			return

		getNetwork: ->
			q = $q.defer()
			do cordovaReady =>
				q.resolve navigator.connection.type
			q.promise

		isOnline: ->
			q = $q.defer()
			do cordovaReady =>
				networkState = navigator.connection.type
				q.resolve networkState != Connection.UNKNOWN and networkState != Connection.NONE
			q.promise

		isOffline: ->
			q = $q.defer()
			do cordovaReady =>
				networkState = navigator.connection.type
				q.resolve networkState == Connection.UNKNOWN or networkState == Connection.NONE
			q.promise

		clearOfflineWatch: ->
			do cordovaReady =>
				document.removeEventListener 'offline', offlineEvent
				$rootScope.$$listeners['$cordovaNetwork:offline'] = []
			return

		clearOnlineWatch: ->
			do cordovaReady =>
				document.removeEventListener 'online', offlineEvent
				$rootScope.$$listeners['$cordovaNetwork:online'] = []
			return

]

.run [
	'$cordovaNetwork'
	($cordovaNetwork) ->
]