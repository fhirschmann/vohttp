vohttp = {}

function declare(name, value)
    _G[name] = value
end

function printtable(t)
    for i, v in ipairs(t) do
        print(i..": "..v)
    end
end

dofile("../lib/tcpsock.lua")
dofile("../util.lua")
dofile("../server.lua")
dofile("../request.lua")

r = {"GET /foo/?bar=foo&foo=bar HTTP/1.1", "foo"}

request = vohttp.Request:new(r)
printtable(vohttp.util.decode("foo=bar"))
