dofile("lib/tcpsock.lua")

declare("vohttp", vohttp or {})
dofile("util.lua")
dofile("request.lua")
dofile("response.lua")
dofile("server.lua")

local function serve(req)
    local r = vohttp.response.Response:new()
    r.body = "<html><head><h1>Hello</h1>Hi there.</head></html>"
    return r
end

server = vohttp.Server:new()
server:add_route("/", serve)

local function start()
    server:start(9000)
end

local function stop()
    server:stop()
end

local function reload()
    stop()
    ReloadInterface()
end

RegisterUserCommand("s1", start)
RegisterUserCommand("s2", stop)
RegisterUserCommand("s3", reload)
start()