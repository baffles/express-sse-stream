###
Simple demo example that just sends a stream of the current server time.
###

express = require 'express'
app = express()

# would be require 'express-sse-stream' when installed from npm
{sse} = require '../lib/express-sse-stream'

page = """
<html>
	<head>
		<title>express-sse-stream sample</title>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
		<script type="text/javascript">
			var eventSource = new EventSource("/stream")
			eventSource.onmessage = function(e) {
				$('#time').text(e.data)
			}
		</script>
	</head>
	<body>
	<p>Current time: <span id="time">(waiting)</span></p>
	</body>
</html>
"""

app.get '/', (req, res) ->
	res.set 'Content-Type', 'text/html'
	res.send page

id = 0

app.get '/stream', sse(), (req, res) ->
	thisId = id++
	console.log "sse stream #{thisId} opened"
	sendTime = () ->
		time = new Date().toLocaleString()
		console.log "sending time #{thisId} - #{time}"
		req.sse.stream.write data: time
	sender = setInterval sendTime, 1000
	req.sse.stream.on 'finish', ->
		console.log "sse stream #{thisId} closed"
		clearInterval sender

server = app.listen 3000, ->
	console.log "Listening at http://#{server.address().address}:#{server.address().port}"
