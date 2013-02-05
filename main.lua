declare("vohttp", vohttp or {})

--- enable debug messages globally
vohttp.DEBUG = vohttp.DEBUG or false

function vohttp.debug_print(msg)
    if vohttp.DEBUG then
        print(msg)
    end
end

dofile("util.lua")
dofile("request.lua")
dofile("response.lua")
dofile("dispatch.lua")
dofile("server.lua")
