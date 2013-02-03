# vohttp
vohttp is an HTTP library for [Vendetta Online](http://vendetta-online.com)
that includes an HTTP server.

## Usage

The following snippet will start listening on port
9000 and dispatch all requests to `/` to the function
`serve`:

    local function serve(req)
        local r = vohttp.response.Response:new()
        r.body = "<html><body><h1>test</h1>foo</body></html>"
        return r
    end

    server = vohttp.Server:new()
    server:add_route("/", serve)
    server.start(9000)

Of course, you can also access GET data:

    local function serve(req)
        local r = vohttp.response.Response:new()
        r.headers["Content-Type"] = "text/plain"
        r.body = "You said: "..req.get_data["say"]
        return r
    end

    server = vohttp.Server:new()
    server:add_route("/", serve)
    server.start(9000)

and point your browser to [http://localhost:9000/?say=hello](http://localhost:9000/?say=hello)

## Documentation
Please [find the documentation](http://fhirschmann.github.com/vohttp) here
at Github.
