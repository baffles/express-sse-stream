# express-sse-stream

Middleware for express providing writeable SSE streams.

## Use

To use [express-sse-stream](https://www.npmjs.com/package/express-sse-stream), first install it from npm: `npm install express-sse-stream`.

First, you'll want to require the library:

`var sse = require('express-sse-stream').sse`

Then, to actually create an SSE stream, install it as middleware on whatever routes you want:

	app.get('/stream', sse(), function(req, res) {
		// req.sse contains the SSE stream information
		//        .stream is a node object stream you can push SSE data to
		//        .lastEventId is the last event ID specified by the browser, if applicable
		function sendTime() {
			var time = new Date().toLocaleString()
			req.sse.stream.write({ data: time })
		}

		var sender = setInterval(sendTime, 1000)

		req.sse.stream.on 'finish', function() {
			clearInterval(sender)
		}
	})

Simple as that!
