(function() {
  var JsonrpcClient, scopedClient;
  scopedClient = require('scoped-http-client');
  JsonrpcClient = (function() {
    JsonrpcClient.errorCodes = {
      '-32700': 'JSON-RPC server reported a parse error in JSON request',
      '-32600': 'JSON-RPC server reported an invalid request',
      '-32601': 'Method not found',
      '-32602': 'Invalid parameters',
      '-32603': 'Internal error'
    };
    function JsonrpcClient(endpoint) {
      this.client = scopedClient.create(endpoint).header('Accept', 'application/json');
    }
    JsonrpcClient.prototype.call = function(method, params, callback) {
      var jsonParams, requestString;
      jsonParams = {
        jsonrpc: '2.0',
        id: (new Date).getTime(),
        method: method,
        params: params
      };
      requestString = JSON.stringify(jsonParams);
      return this.client.scope('').post(requestString)(function(error, response, body) {
        var decodedResponse, errorMessage, _base, _name;
        if (error) {
          callback(error, body);
          return;
        }
        try {
          decodedResponse = JSON.parse(body);
        } catch (decodeError) {
          callback('Could not decode JSON response', body);
          return;
        }
        if (decodedResponse.error) {
          errorMessage = (_base = JsonrpcClient.errorCodes)[_name = decodedResponse.error.code] || (_base[_name] = "Unknown error");
          errorMessage += " " + decodedResponse.error.message;
          callback(errorMessage, decodedResponse.error.data);
          return;
        }
        return callback(null, decodedResponse.result);
      });
    };
    return JsonrpcClient;
  })();
  exports.create = function(endpoint, options) {
    return new JsonrpcClient(endpoint, options);
  };
}).call(this);
