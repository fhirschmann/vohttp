declare("vohttp", vohttp or {})

vohttp.DEBUG = gkini.ReadString("vohttp", "debug", 0) == 1

function vohttp.debug_print(msg)
    if vohttp.DEBUG then
        print(msg)
    end
end

dofile("lib/tcpsock.lua")
dofile("util.lua")
dofile("request.lua")
dofile("response.lua")
dofile("dispatch.lua")
dofile("server.lua")
