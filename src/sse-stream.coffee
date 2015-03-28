###
SSEStream is the writable stream that does the heavy lifting of actually managing SSE connections
###

stream = require 'stream'

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

		@response.write encoder.comment options.headerComment if @options.headerComment?
		@response.write encoder.packet retry: options.retry if @options.retry?

		request.on 'close', => @end()

		@on 'finish', =>
			@stopKeepalive()
			@response.end()

	startKeepalive: (interval) ->
		return if @keepalive?
		keepalive = =>
			@response.write module.exports.encoder.comment '' if @lastSend + interval <= Date.now()
		@keepalive = setInterval keepalive, interval

	stopKeepalive: ->
		return if not @keepalive?
		clearInterval @keepalive
		delete @keepalive

	_write: (data, encoding, callback) ->
		try
			if typeof data is 'string'
				data = data: data
			else
				data.data = JSON.stringify data.data if typeof data isnt 'string'

			@response.write module.exports.encoder.packet data
			@lastSend = Date.now()

			callback()
		catch ex
			callback ex
