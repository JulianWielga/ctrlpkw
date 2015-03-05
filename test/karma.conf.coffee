# Karma configuration
# Generated on Wed Aug 06 2014 17:23:59 GMT+0200 (CEST)
module.exports = (config) ->
	config.set

		# base path that will be used to resolve all patterns (eg. files, exclude)
		basePath: "../"

		# frameworks to use
		# available frameworks: https://npmjs.org/browse/keyword/karma-adapter
		frameworks: ["jasmine"]

		# list of files / patterns to load in the browser
		files: [
			"_public/js/vendor.js"
			"_public/js/config.js"
			"_public/js/templates.js"
			"vendor/**/*.js"
			"vendor/**/*.coffee"
			"app/**/*.coffee"
			"bower_components/angular-mocks/angular-mocks.js"
			"test/unit/**/*.coffee"
		]

		# list of files to exclude
		exclude: []

		# test results reporter to use
		# possible values: 'dots', 'progress'
		# available reporters: https://npmjs.org/browse/keyword/karma-reporter
		reporters: [
			"progress"
			"junit"
			"coverage"
		]

		# preprocess matching files before serving them to the browser
		# available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
		preprocessors:
			"app/**/*.coffee": [
				"coffee"
				"coverage"
			]
			"vendor/**/*.coffee": [
				"coffee"
				"coverage"
			]
			"vendor/**/*.js": ["coverage"]
			"test/unit/**/*.coffee": ["coffee"]

		coverageReporter:
			reporters: [
				{
					type: "cobertura"
				}
				{
					type: "text-summary"
				}
			]
			instrumenter:
				"**/*.coffee": "istanbul" # Force the use of the Istanbul instrumenter to cover CoffeeScript files


		# web server port
		port: 9876

		# enable / disable colors in the output (reporters and logs)
		colors: true

		# level of logging
		# possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
		logLevel: config.LOG_INFO

		# enable / disable watching file and executing tests whenever any file changes
		autoWatch: true

		# start these browsers
		# available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
		browsers: [
			"PhantomJS"
#			'Chrome'
		]

		# Continuous Integration mode
		# if true, Karma captures browsers, runs the tests and exits
		singleRun: false