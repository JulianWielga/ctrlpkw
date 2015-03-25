'use strict'

angular.module 'main.resources.cloudinary', []

.factory 'CloudinaryResources', [
	'$resource'
	($resource) ->
		apiUrl = 'https://api.cloudinary.com/v1_1'
		cloudName = 'ddj4jx8rq'
		$resource "#{apiUrl}/#{cloudName}/image/upload"
]