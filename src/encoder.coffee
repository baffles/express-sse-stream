###
Handles encoding SSE data packets
###

number = /^\d+$/
invalid = /[\r\n]/
newline = /\r?\n/
separator = '\n'

buildComment = (comment) -> (": #{line}" for line in comment.split newline).join(separator) + separator

module.exports.encoder =
	comment: (comment) -> buildComment(comment) + separator
	packet: (data) ->
		throw 'invalid id' if data.id? and typeof data.id isnt 'number' and data.id.search(invalid) >= 0
		throw 'invalid event' if data.event?.search(invalid) >= 0
		throw 'invalid retry' if data.retry? and typeof data.retry isnt 'number' and not number.test data.retry

		packet = ''

		packet += buildComment data.comment if data.comment?
		packet += "id: #{data.id}#{separator}" if data.id?
		packet += "event: #{data.event}#{separator}" if data.event?
		packet += "retry: #{data.retry}#{separator}" if data.retry?
		packet += "data: #{line}#{separator}" for line in data.data.split newline if data.data?
		packet += separator if packet.length > 0

		packet
