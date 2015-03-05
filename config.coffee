exports.config =
# See docs at http://brunch.readthedocs.org/en/latest/config.html.
	conventions:
		assets: /^app[\/\\]assets/
		ignored: /^(bower_components[\/\\]bootstrap-less(-themes)?|app[\/\\]styles[\/\\]overrides|(.*?[\/\\])?[_]\w*)/
	modules:
		definition: false
		wrapper: false
	paths:
		public: 'www'
		watched: ['app', 'vendor']
	files:
		javascripts:
			joinTo:
				'js/app.js': /^app/
				'js/vendor.js': /^(bower_components|vendor)/
			order:
				before: [
					'bower_components/underscore/underscore.js'
				]

		stylesheets:
			joinTo:
				'css/vendor.css': /^(vendor|bower_components)/
				'css/app.css': /^(app)/
			order:
				before: [
					'app/styles/bootstrap/bootstrap.less'
				]
				after: []

		templates:
			joinTo:
				'js/templates.js': /^app.*[\/\\]templates[\/\\].*jade$/

	plugins:
		jadeNgtemplates:
			modules: [
				name: "app.templates"
				pattern: /^app.*[\/\\]templates[\/\\].*jade$/
				url: (path) ->
					path.replace /.*[\/\\](.*)\.jade$/, '/templates/$1.html'
			]
			jade:
				pretty: yes
				doctype: "xml"
				basedir: 'app'
			htmlmin: no

		jadePages:
			pattern: /^app[\/\\]index.jade$/
			jade:
				pretty: yes
				doctype: "xml"
				basedir: 'app'
			htmlmin: no


	overrides:
		production:
			optimize: true #nie działa ta opcja na js - zawsze true
			sourceMaps: false


	server:
		port: 3334
		base: '/'

# export server configuration to jade processor
process?.server = exports.config.server
