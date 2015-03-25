# install   :   cordova plugin add org.apache.cordova.camera
# link      :   https://github.com/apache/cordova-plugin-camera/blob/master/doc/index.md#orgapachecordovacamera

angular.module 'ngCordova.plugins.camera', [
	'cordova.Ready'
]

.factory '$cordovaCamera', [
	'$q', 'crdReady'
	($q, cordovaReady) ->
		getPicture: (options) ->
			q = $q.defer()
			do cordovaReady ->
				if !navigator.camera
					q.resolve null
					return q.promise
				navigator.camera.getPicture ((imageData) ->
					q.resolve imageData
				), ((err) ->
					q.reject err
				), options
			q.promise

		cleanup: ->
			q = $q.defer()
			do cordovaReady ->
				navigator.camera.cleanup ->
					q.resolve()
				, (err) ->
					q.reject err
			q.promise
]
