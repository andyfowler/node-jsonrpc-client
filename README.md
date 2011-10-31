JSON-RPC Client for Node.js
===========================

A dead-simple JSON-RPC client for Node.js, built on top of [scoped-http-client][] in [Coffeescript][coffeescript]. Generally adheres to the incomplete [JSON-RPC 2.0 spec][spec] -- earlier specs didn't support named parameters. Released under the MIT license. 

Why this package?
-----------------

* Supports both HTTP and HTTPS
* Relies on [scoped-http-client][] for HTTP idiosyncrasies. Other implementations use Node's low-level HTTP client
* The other JSON-RPC implementations are primarily servers -- this is a simple client

Usage (Javascript)
------------------

    jsonrpc = require('jsonrpc-client');
    
    client = jsonrpc.create('https://myapp.com/api');
    
    client.call(
        'myRemoteMethod', 
        { someParam: 'someValue' }, 
        function(error, response) {
           if (error === null) {
               console.log(response.someResponseParam)
           }
        }
    );

Development
-----------
**To run tests:**
    
    cd node-jsonrpc-client
    npm install --dev
    cake test

Tests are run against the Coffeescript source files. No need to `cake build` unless you're packaging for release.

Todo
----
 * Support HTTP authentication
 * Consider a streaming JSON parser like [benejson](https://github.com/codehero/benejson)

[scoped-http-client]: https://github.com/technoweenie/node-scoped-http-client
[coffeescript]: http://jashkenas.github.com/coffee-script/
[spec]: http://jsonrpc.org/spec.html