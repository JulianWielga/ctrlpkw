'use strict'

angular.module 'touk.promisedLink', []

.directive 'promisedFn', [
	'$timeout'
	'$parse'
	($timeout, $parse)->
		restrict: 'A'
		link: (scope, element, attrs) ->
			fnGetter = null

			attrs.$observe 'promisedFn', (fn) ->
				fnGetter = $parse(fn) or fn

			simulateDefault = (event) ->
				touch = event.changedTouches?[0] or event
				$timeout ->
					newEvent = document.createEvent "MouseEvents"
					newEvent.initMouseEvent "click", true, true, window, 1, touch.screenX, touch.screenY, touch.clientX, touch.clientY, event.ctrlKey, event.altKey, event.shiftKey, event.metaKey, event.button, null
					newEvent.preventedDefault = yes
					newEvent.stopPropagation()
					element[0].dispatchEvent newEvent

			element.on 'click', (event) ->
				return if event.originalEvent?.preventedDefault or event?.preventedDefault
				event.preventDefault()
				fnGetter?(scope).then? -> simulateDefault(event)
]