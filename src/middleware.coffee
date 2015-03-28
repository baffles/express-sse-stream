###
Express middleware to facilitate setting up SSE streams
###

module.exports.sse = (options={}) ->
	(req, res, next) ->
		# check that Accept, if sent, contains text/event-stream?
		req.sse =
			lastEventId: req.get 'Last-Event-ID'
			stream: new module.exports.SSEStream req, res, options
		return next()
		#else
		#	return next 'invalid SSE request'
