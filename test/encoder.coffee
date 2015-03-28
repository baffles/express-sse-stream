should = require('chai').should()

{encoder} = require '../lib/express-sse-stream'

describe 'SSE Encoder', ->

	it 'should render comments properly', ->
		encoded = encoder.comment 'test'
		encoded.should.equal ': test\n\n'

	it 'should render multi-line comments properly', ->
		encoded = encoder.comment 'line1\nline2'
		encoded.should.equal ': line1\n: line2\n\n'

	it 'should render comments in packets', ->
		encoded = encoder.packet comment: 'test'
		encoded.should.equal ': test\n\n'

	it 'should render multi-line comments in packets', ->
		encoded = encoder.packet comment: 'line1\nline2'
		encoded.should.equal ': line1\n: line2\n\n'

	it 'should render IDs', ->
		encoded = encoder.packet id: 12
		encoded.should.equal 'id: 12\n\n'

	it 'should throw for invalid IDs', ->
		(-> encoder.packet id: '13\r').should.throw 'invalid id'
		(-> encoder.packet id: '13\n').should.throw 'invalid id'

	it 'should render event types', ->
		encoded = encoder.packet event: 'foo'
		encoded.should.equal 'event: foo\n\n'

	it 'should throw for invalid event types', ->
		(-> encoder.packet event: 'bad\r').should.throw 'invalid event'
		(-> encoder.packet event: 'bad\n').should.throw 'invalid event'

	it 'should render retry values', ->
		encoded = encoder.packet retry: 1000
		encoded.should.equal 'retry: 1000\n\n'

	it 'should throw for invalid retry values', ->
		(-> encoder.packet retry: 'bad').should.throw 'invalid retry'
		(-> encoder.packet retry: '12xx').should.throw 'invalid retry'

	it 'should render simple data', ->
		encoded = encoder.packet data: 'test'
		encoded.should.equal 'data: test\n\n'

	it 'should render multi-line data', ->
		encoded = encoder.packet data: 'test1\ntest2'
		encoded.should.equal 'data: test1\ndata: test2\n\n'

	it 'should handle complex packets', ->
		encoded = encoder.packet id: 'foo', event: 'test', retry: 20000, data: 'line1\nline2\nline3'
		lines = encoded.split '\n'
		lines.length.should.equal 8 # id, event, retry, 3 lines for data, empty line at end
		lines.should.include 'id: foo'
		lines.should.include 'event: test'
		lines.should.include 'retry: 20000'

		# also, make sure data lines are rendered in order
		encoded.should.contain 'data: line1\ndata: line2\ndata: line3'
