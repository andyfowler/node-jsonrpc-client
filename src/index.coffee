scopedClient = require 'scoped-http-client'

# http://jsonrpc.org/spec.html
class JsonrpcClient
  
  @errorCodes:
    '-32700': 'JSON-RPC server reported a parse error in JSON request'
    '-32600': 'JSON-RPC server reported an invalid request'
    '-32601': 'Method not found'
    '-32602': 'Invalid parameters'
    '-32603': 'Internal error'
  
  constructor: (endpoint) ->
    @client = scopedClient.create(endpoint)
                          .header 'Accept', 'application/json'
    
  call: (method, params, callback) ->
    jsonParams =
      jsonrpc: '2.0'
      id:       (new Date).getTime()
      method:   method
      params:   params
    
    requestString = JSON.stringify jsonParams
    
    @client.scope('').post(requestString) (error, response, body) ->
      # http errors
      if error
        callback error, body
        return

      # response json parse errors
      try
        decodedResponse = JSON.parse body
      catch decodeError
        callback 'Could not decode JSON response', body
        return
        
      # json-rpc errors
      if decodedResponse.error
        errorMessage = JsonrpcClient.errorCodes[decodedResponse.error.code] or= "Unknown error"
        errorMessage += " #{decodedResponse.error.message}"
        callback errorMessage, decodedResponse.error.data
        return
      
      callback null, decodedResponse.result
      
      
exports.create = (endpoint, options) ->
  new JsonrpcClient endpoint, options