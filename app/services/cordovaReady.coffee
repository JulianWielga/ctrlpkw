'use strict'

angular.module 'cordova.Ready', [
	'touk.jwl.ngFnQueue'
]

.factory 'crdReady', [
	'$q', '$document', 'fnQueue'
	($q, $document, fnQueue) ->
		deferred = $q.defer()
		$document.one 'deviceready', -> deferred.resolve()
		return fnQueue(deferred.promise)
]
