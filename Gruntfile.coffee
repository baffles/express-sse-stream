module.exports = (grunt) ->
	grunt.initConfig
		coffee:
			compile:
				files:
					'lib/express-sse-stream.js': [ 'src/*.coffee' ]
		mochaTest:
			options:
				reporter: 'nyan'
			src: [ 'test/*.coffee' ]

	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-mocha-test'

	grunt.registerTask 'default', [ 'coffee', 'mochaTest' ]
