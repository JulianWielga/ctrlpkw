'use strict'

angular.module 'RequestContext', []

.service 'requestContext', [
	'RenderContext'
	class RequestContext
		action: ""
		sections: []
		params: {}
		previousAction: ""
		previousParams: {}

		constructor: (@RenderContext) ->

		getAction: => @action

		getNextSection: (prefix) =>
			return null unless @startsWith prefix
			return @sections[0] if prefix is ""

			depth = prefix.split(".").length

			return null if depth is @sections.length

			@sections[depth]

		getParam: (name, defaultValue) =>
			defaultValue = null if angular.isUndefined(defaultValue)
			@params[name] or defaultValue

		getParamAsInt: (name, defaultValue) =>
			valueAsInt = @getParam(name, defaultValue or 0) * 1

			if isNaN(valueAsInt)
				defaultValue or 0
			else
				valueAsInt

		getRenderContext: (requestActionLocation, paramNames) =>
			requestActionLocation ?= ""
			paramNames ?= []
			paramNames = [paramNames] unless angular.isArray(paramNames)
			new @RenderContext(this, requestActionLocation, paramNames)

		hasActionChanged: =>
			@action isnt @previousAction

		hasParamChanged: (paramName, paramValue) =>
			return not @isParam(paramName, paramValue) unless angular.isUndefined(paramValue)

			unless @previousParams.hasOwnProperty(paramName) and @params.hasOwnProperty(paramName)
				return true
			else
				return true if @previousParams.hasOwnProperty(paramName) and not @params.hasOwnProperty(paramName)

			@previousParams[paramName] isnt @params[paramName]

		haveParamsChanged: (paramNames) =>
			for param in paramNames
				return true if @hasParamChanged param
			false

		isParam: (paramName, paramValue) =>
			@params.hasOwnProperty(paramName) and (@params[paramName] is paramValue)

		setContext: (newAction, newRouteParams) =>
			@previousAction = @action
			@previousParams = @params

			@action = newAction
			@sections = @action.split(".")

			@params = angular.copy(newRouteParams)

		startsWith: (prefix) =>
			not prefix.length or (@action is prefix) or (@action.indexOf(prefix + ".") is 0)

]

.value 'RenderContext', (requestContext, actionPrefix, paramNames) ->
	getNextSection: ->
		requestContext.getNextSection actionPrefix

	isChangeLocal: ->
		requestContext.startsWith actionPrefix

	isChangeRelevant: ->
		return false unless requestContext.startsWith(actionPrefix)
		return true if requestContext.hasActionChanged()
		paramNames.length and requestContext.haveParamsChanged(paramNames)

	getParam: requestContext.getParam
	getParamAsInt: requestContext.getParamAsInt

.factory 'RenderContextFactory', [
	'requestContext', (requestContext) ->
		(@scope, context, params) ->
			@renderContext = requestContext.getRenderContext context, params
			@scope.subview = @renderContext.getNextSection()

			@scope.$on "requestContextChanged", =>
				return unless @renderContext.isChangeRelevant()
				@scope.subview = @renderContext.getNextSection()

			return @renderContext
]
