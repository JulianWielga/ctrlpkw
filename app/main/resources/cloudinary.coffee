'use strict'

angular.module 'main.resources.cloudinary', [
	'config.vars'
]

.factory 'CloudinaryResources', [
	'$resource', 'varsConfig'
	($resource, config) ->
		$resource "#{config.cloudinary}/#{config.cloudName}/image/upload"
]