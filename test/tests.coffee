# the json-rpc spec has always been fuzzy, but see http://jsonrpc.org/spec.html
# 

nock            = require('nock')
jsonrpc         = require('../src/index.coffee')
endpoint        = 'http://example.com'

createNockWithResponse = (string, statusCode = 200) ->
  return nock(endpoint)
    .filteringRequestBody (body) ->    # instruct nock to disregard the request for this test
      return ''
    .post('/')
    .reply(statusCode, string) 

module.exports =
  "Creates good request": (test) ->
    nockscope = nock(endpoint)
      .filteringRequestBody(/"id":.*?,/g, '"id":"xxx",') # disregard changing request IDs
      .post('/', {
        jsonrpc: '2.0'
        id: 'xxx',
        method: 'goodRequest'
        params: { foo: true }
      })
      .reply(200, '{"result": {"good": "great"} }')
      
    jsonrpc.create(endpoint).call 'goodRequest', { foo: true }, (error, response) ->
      test.ok(error == null)
      nockscope.done() # asserts that we actually hit and matched the nock listener
      test.done()

  
  "Handles good response": (test) ->
    createNockWithResponse '{"result": {"good": "great"} }'
      
    jsonrpc.create(endpoint).call 'goodResponse', { foo: true }, (error, response) ->
      test.deepEqual response, { good: 'great' }
      test.done()


  # the spec is undecided on http status codes, so this client ignores them
  # as long as it gets back good result json
  # 
  "Ignores HTTP status": (test) ->
    createNockWithResponse '{"result": {"good": "great"} }', 404

    jsonrpc.create(endpoint).call 'someRequest', { foo: true }, (error, response) ->
      test.deepEqual response, { good: 'great' }
      test.done()
    
    
  "Handles errors from spec": (test) ->
    createNockWithResponse '{"error": {"code": -32601, "message":"Server generated error"} }', 500

    jsonrpc.create(endpoint).call 'nonexistantMethod', { foo: true }, (error, response) ->
      test.ok(error?)
      test.ok(error.match(/Method not found/))        # internal json-rpc client message
      test.ok(error.match(/Server generated error/))  # whatever the server told us
      test.done()


  "Handles application errors": (test) ->
    createNockWithResponse '{"error": {"code": 1234, "message":"Server generated error", "data": 5678} }', 500

    jsonrpc.create(endpoint).call 'badRemote', { foo: true }, (error, response) ->
      test.ok(error?)
      test.ok(error.match(/Server generated error/))  # whatever the server told us
      test.equal response, '5678'
      test.done()
      
  "Handles bad JSON": (test) ->
    createNockWithResponse '{"result": 123klsf]]]', 200

    jsonrpc.create(endpoint).call 'badRemote', { foo: true }, (error, response) ->
      test.ok(error?)
      test.ok(error.match(/JSON/))
      test.done()