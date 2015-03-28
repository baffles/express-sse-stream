###
SSEStream is the writable stream that does the heavy lifting of actually managing SSE connections
###

stream = require 'stream'

invalid = /[\r\n]/
newline = /\r?\n/

module.exports.SSEStream = class SSEStream extends stream.Writable
	constructor: (request, response, @options={}) ->
		super objectMode: true
		@init request, response
		@startKeepalive @options.keepaliveInterval if @options.keepaliveInterval?

	init: (request, @response) ->
		# we're taking over the request/response, so set everything up
		request.socket.setTimeout 0
		@response.statusCode = 200
		@response.setHeader 'Content-Type', 'text/event-stream'
		@response.setHeader 'Cache-Control', 'no-cache'
		@response.setHeader 'Connection', 'keep-alive'

		@response.write ": #{options.headerComment}" if @options.headerComment?
		@response.write "retry: #{@options.retry}" if @options.retry?

		@response.write "\n\n"

		request.on 'close', => @end()

		@on 'finish', =>
			@stopKeepalive()
			@response.end()

	startKeepalive: (interval) ->
		return if @keepalive?
		keepalive = =>
			@response.write ':\n\n' if @lastSend + interval <= Date.now()
		@keepalive = setInterval keepalive, interval

	stopKeepalive: ->
		return if not @keepalive?
		clearInterval @keepalive
		delete @keepalive

	doWrite: (data, cb) ->
		if typeof data is 'string'
			data = data: data
		else
			data.data = JSON.stringify data.data

		return cb 'invalid id' if data.id?.search(invalid) >= 0
		return cb 'invalid event' if data.id?.search(invalid) >= 0

		@response.write "id: #{data.id}\n" if data.id?
		@response.write "event: #{data.event}\n" if data.event?
		@response.write "retry: #{data.retry}\n" if data.retry?

		@response.write "data: #{line}\n" for line in data.data.split newline

		@response.write '\n\n'
		@lastSend = Date.now()

		cb()

	_write: (data, encoding, callback) ->
		@doWrite data, callback
