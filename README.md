# vohttp
vohttp is an HTTP library for [Vendetta Online](http://vendetta-online.com)
that includes an HTTP server.

## Installation

### Downloading a prepacked version

You can fetch the current prepacked version of this library from
[this site](http://dl.0x0b.de/vohttp/).

### Packing from the repository
Because I found the current way of distributing 3rd party
libraries for Vendetta Online unsatisfying (multiple plugins loading different
versions of the same library into the global namespace), installation
of this library works a little different.

First, you'll have to pull the repository from github:

    git clone http://github.com/fhirschmann/vohttp.git

Afterwards, you have to pack all of the library's files into
a single file. You can do so by executing:

    cd vohttp
    make

You can now find a packed version of the library in the `out`
directory. You can distribute this file with your plugin
and load it like so:

    local vohttp = dofile("vohttp_packed.lua")

If you intend to use vohttp in several files in your plug-in, I recommend
to do the following in your main.lua:

    mylib = {}
    mylib.http = dofile("vohttp_packed.lua")

## Usage

The following snippet will start listening on port
9000 and dispatch all requests to `/` to the function
`serve`

    local vohttp = dofile("vohttp_packed.lua")

    local function serve(req)
        local r = vohttp.response.Response:new()
        r.body = "<html><body><h1>test</h1>foo</body></html>"
        return r
    end

    server = vohttp.Server:new()
    server:add_route("/", serve)
    server.start(9000)

Of course, you can also access GET data:

    local vohttp = dofile("vohttp_packed.lua")

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

### Static Files
This library provides a dispatcher that can be used to serve
static files (such as CSS and JavaScript). If you wish to
do so, please follow the next two steps.

#### Encapsulating Static Files
Because you can only read from Lua files in Vendetta Online,
you need to encapsulate your static content in such a Lua file.

In order to do so yourself, simply create a file named
`style.css.lua` with the following content:

    return [[[
    body {
        color: #000;
    }
    ]]]

This library also ships with a tool named `tools/encapsulate`
that scans for files in a given directory and creates an
encapsulated file for each file found:

    tools/volucapsulate media/js


#### Serving Encapsulated Files
    server:add_route("/style.css",
                     http.dispatch.StaticFile:new("media/css/style.css.lua")

Please note that you need to reload Vendetta Online's
Interface when you change your static files.

## Documentation
Please [find the documentation here](http://dl.0x0b.de/vohttp/vohttp-0.5/doc/).
